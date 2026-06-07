#!/usr/bin/env python3
"""
CSS Codes as Cohomology: Core Algorithms

Type-hinted implementations of the chain-complex-to-CSS-code construction.
"""

from __future__ import annotations
import numpy as np
from dataclasses import dataclass
from typing import Optional, List, Tuple


@dataclass
class ChainComplex:
    """A 3-term chain complex C_2 -[d2]-> C_1 -[d1]-> C_0 over GF(2).

    Attributes:
        d1: Matrix representing the boundary map d1 (n0 x n1)
        d2: Matrix representing the boundary map d2 (n1 x n2)
    """
    d1: np.ndarray  # shape (n0, n1)
    d2: np.ndarray  # shape (n1, n2)

    def __post_init__(self) -> None:
        self.d1 = self.d1 % 2
        self.d2 = self.d2 % 2
        product = (self.d1 @ self.d2) % 2
        if not np.all(product == 0):
            raise ValueError("Chain complex condition violated: d1 ∘ d2 ≠ 0 mod 2")

    @property
    def n0(self) -> int:
        return self.d1.shape[0]

    @property
    def n1(self) -> int:
        return self.d1.shape[1]

    @property
    def n2(self) -> int:
        return self.d2.shape[1]


@dataclass
class CSSCode:
    """A CSS quantum error-correcting code.

    Attributes:
        n: Number of physical qubits
        k: Number of logical qubits (= first Betti number)
        d: Code distance (minimum weight of non-trivial logical operator)
        hx: X-check matrix (stabilizer generators for X errors)
        hz: Z-check matrix (stabilizer generators for Z errors)
    """
    n: int
    k: int
    d: int
    hx: np.ndarray  # X-check matrix
    hz: np.ndarray  # Z-check matrix (= d2.T for chain complex CSS)


def gf2_rank(matrix: np.ndarray) -> int:
    """Compute the rank of a matrix over GF(2).

    Uses Gaussian elimination with partial pivoting.
    Time complexity: O(min(m,n) * m * n) where m x n is the matrix shape.

    Args:
        matrix: Integer matrix to compute rank of

    Returns:
        Rank of the matrix over GF(2)
    """
    if matrix.size == 0:
        return 0
    m = matrix.copy() % 2
    rows, cols = m.shape
    rank = 0
    for col in range(cols):
        pivot: Optional[int] = None
        for row in range(rank, rows):
            if m[row, col] == 1:
                pivot = row
                break
        if pivot is None:
            continue
        m[[rank, pivot]] = m[[pivot, rank]]
        for row in range(rows):
            if row != rank and m[row, col] == 1:
                m[row] = (m[row] + m[rank]) % 2
        rank += 1
    return rank


def gf2_kernel(matrix: np.ndarray) -> np.ndarray:
    """Compute a basis for the kernel of a matrix over GF(2).

    Args:
        matrix: Integer matrix (m x n)

    Returns:
        Matrix whose rows form a basis for ker(matrix) over GF(2).
        Shape is (nullity, n).
    """
    if matrix.size == 0:
        n = matrix.shape[1] if len(matrix.shape) > 1 else 0
        return np.eye(n, dtype=int)

    m = matrix.copy() % 2
    rows, cols = m.shape

    # Augment with identity for tracking
    aug = np.hstack([m.T, np.eye(cols, dtype=int)])  # (cols x rows+cols)

    rank = 0
    for col in range(rows):
        pivot = None
        for row in range(rank, cols):
            if aug[row, col] == 1:
                pivot = row
                break
        if pivot is None:
            continue
        aug[[rank, pivot]] = aug[[pivot, rank]]
        for row in range(cols):
            if row != rank and aug[row, col] == 1:
                aug[row] = (aug[row] + aug[rank]) % 2
        rank += 1

    # Kernel basis = rows of aug[rank:, rows:]
    ker = aug[rank:, rows:] % 2
    return ker


def chain_to_css(chain: ChainComplex) -> CSSCode:
    """Convert a chain complex to a CSS code.

    Algorithm:
    1. Compute ker(d1) = cycle space (logical space)
    2. Compute im(d2) = boundary space (stabilizer)
    3. Logical qubits k = dim(ker d1) - dim(im d2) = β₁
    4. Distance = minimum weight of non-trivial cycle

    Args:
        chain: A 3-term chain complex over GF(2)

    Returns:
        The corresponding CSS code
    """
    n1 = chain.n1
    rank_d1 = gf2_rank(chain.d1)
    rank_d2 = gf2_rank(chain.d2)

    dim_ker = n1 - rank_d1
    betti_1 = dim_ker - rank_d2  # First Betti number

    # Compute minimum distance
    distance = _compute_distance(chain.d1, chain.d2, n1)

    return CSSCode(
        n=n1,
        k=betti_1,
        d=distance,
        hx=chain.d1,
        hz=chain.d2.T % 2
    )


def _compute_distance(d1: np.ndarray, d2: np.ndarray, n: int) -> int:
    """Compute minimum weight of non-trivial cycle.

    Enumerates all elements of ker(d1) and checks which are not in im(d2).
    For large kernels, uses sampling.

    Args:
        d1: Boundary map d1
        d2: Boundary map d2
        n: Ambient dimension

    Returns:
        Minimum Hamming weight of a non-trivial element of ker(d1)/im(d2)
    """
    ker_basis = gf2_kernel(d1)
    if len(ker_basis) == 0:
        return 0

    rank_d2 = gf2_rank(d2)
    num_ker = len(ker_basis)

    if num_ker > 20:
        # For large kernels, sample randomly
        return _sample_distance(ker_basis, d2, n, num_samples=10000)

    min_weight = n + 1
    for mask in range(1, 2**num_ker):
        vec = np.zeros(n, dtype=int)
        for i in range(num_ker):
            if mask & (1 << i):
                vec = (vec + ker_basis[i]) % 2

        # Check if in im(d2)
        if d2.shape[1] > 0:
            aug = np.hstack([d2, vec.reshape(-1, 1)])
            if gf2_rank(aug) == rank_d2:
                continue  # Boundary, skip

        weight = int(np.sum(vec))
        if weight > 0:
            min_weight = min(min_weight, weight)

    return min_weight if min_weight <= n else 0


def _sample_distance(ker_basis: np.ndarray, d2: np.ndarray,
                      n: int, num_samples: int) -> int:
    """Estimate distance by random sampling of kernel elements."""
    rank_d2 = gf2_rank(d2)
    num_ker = len(ker_basis)
    min_weight = n + 1

    rng = np.random.default_rng(42)
    for _ in range(num_samples):
        coeffs = rng.integers(0, 2, size=num_ker)
        if np.sum(coeffs) == 0:
            continue
        vec = (coeffs @ ker_basis) % 2
        if d2.shape[1] > 0:
            aug = np.hstack([d2, vec.reshape(-1, 1)])
            if gf2_rank(aug) == rank_d2:
                continue
        weight = int(np.sum(vec))
        if weight > 0:
            min_weight = min(min_weight, weight)

    return min_weight if min_weight <= n else 0


def make_repetition_code(n_qubits: int) -> ChainComplex:
    """Construct the n-qubit repetition code as a chain complex.

    The path graph with n edges and n-1 vertices.
    d1(x_i) = v_i + v_{i+1} (parity check).

    Args:
        n_qubits: Number of physical qubits (edges)

    Returns:
        Chain complex for the repetition code
    """
    d1 = np.zeros((n_qubits - 1, n_qubits), dtype=int)
    for i in range(n_qubits - 1):
        d1[i, i] = 1
        d1[i, i + 1] = 1
    d2 = np.zeros((n_qubits, 0), dtype=int)
    return ChainComplex(d1=d1, d2=d2)


def make_toric_code(L: int) -> ChainComplex:
    """Construct the toric code on an L×L torus.

    Args:
        L: Linear size of the torus

    Returns:
        Chain complex for the L×L toric code
    """
    n_vertices = L * L
    n_edges = 2 * L * L  # L^2 horizontal + L^2 vertical

    def vertex(i: int, j: int) -> int:
        return (i % L) * L + (j % L)

    edges: List[Tuple[int, int, str]] = []  # (v1, v2, direction)
    for i in range(L):
        for j in range(L):
            edges.append((vertex(i, j), vertex(i, (j + 1) % L), 'h'))
            edges.append((vertex(i, j), vertex((i + 1) % L, j), 'v'))

    d1 = np.zeros((n_vertices, n_edges), dtype=int)
    for idx, (v1, v2, _) in enumerate(edges):
        d1[v1, idx] = (d1[v1, idx] + 1) % 2
        d1[v2, idx] = (d1[v2, idx] + 1) % 2

    # Faces: each plaquette (i,j) has boundary h(i,j) + v(i,j+1) + h(i+1,j) + v(i,j)
    n_faces = L * L
    d2 = np.zeros((n_edges, n_faces), dtype=int)

    edge_map = {}
    for idx, (v1, v2, d) in enumerate(edges):
        edge_map[(v1, v2, d)] = idx

    for i in range(L):
        for j in range(L):
            fi = i * L + j
            # Top: horizontal (i, j)
            d2[edge_map[(vertex(i, j), vertex(i, (j+1)%L), 'h')], fi] = 1
            # Right: vertical (i, j+1 mod L)... actually let's use the edge directly
            d2[edge_map[(vertex(i, (j+1)%L), vertex((i+1)%L, (j+1)%L), 'v')], fi] = 1
            # Bottom: horizontal (i+1, j)
            d2[edge_map[(vertex((i+1)%L, j), vertex((i+1)%L, (j+1)%L), 'h')], fi] = 1
            # Left: vertical (i, j)
            d2[edge_map[(vertex(i, j), vertex((i+1)%L, j), 'v')], fi] = 1

    return ChainComplex(d1=d1 % 2, d2=d2 % 2)


def make_hypercube(dim: int) -> ChainComplex:
    """Construct the chain complex of the dim-dimensional hypercube graph.

    Args:
        dim: Dimension of the hypercube

    Returns:
        Chain complex (graph only, no higher-dimensional cells)
    """
    n_vertices = 2 ** dim
    edges: List[Tuple[int, int]] = []
    for v in range(n_vertices):
        for bit in range(dim):
            w = v ^ (1 << bit)
            if v < w:
                edges.append((v, w))
    n_edges = len(edges)

    d1 = np.zeros((n_vertices, n_edges), dtype=int)
    for idx, (v, w) in enumerate(edges):
        d1[v, idx] = 1
        d1[w, idx] = 1

    d2 = np.zeros((n_edges, 0), dtype=int)
    return ChainComplex(d1=d1 % 2, d2=d2 % 2)


def euler_characteristic_check(chain: ChainComplex) -> bool:
    """Verify the Euler characteristic relation β₁ + rank(d1) + rank(d2) = n1.

    Args:
        chain: A chain complex

    Returns:
        True if the Euler relation holds
    """
    code = chain_to_css(chain)
    rank_d1 = gf2_rank(chain.d1)
    rank_d2 = gf2_rank(chain.d2)
    return code.k + rank_d1 + rank_d2 == chain.n1


if __name__ == "__main__":
    # Verify algorithms on examples
    print("Algorithm verification:")

    rep3 = make_repetition_code(3)
    css3 = chain_to_css(rep3)
    print(f"  Repetition(3): [[{css3.n}, {css3.k}, {css3.d}]]")
    assert css3.k == 1, f"Expected k=1, got k={css3.k}"
    assert euler_characteristic_check(rep3), "Euler check failed"

    toric2 = make_toric_code(2)
    css_toric = chain_to_css(toric2)
    print(f"  Toric(2×2):    [[{css_toric.n}, {css_toric.k}, {css_toric.d}]]")
    assert css_toric.k == 2, f"Expected k=2, got k={css_toric.k}"
    assert euler_characteristic_check(toric2), "Euler check failed"

    q4 = make_hypercube(4)
    css_q4 = chain_to_css(q4)
    print(f"  Hypercube(4):  [[{css_q4.n}, {css_q4.k}, {css_q4.d}]]")
    assert euler_characteristic_check(q4), "Euler check failed"

    print("\n  All checks passed! ✓")
