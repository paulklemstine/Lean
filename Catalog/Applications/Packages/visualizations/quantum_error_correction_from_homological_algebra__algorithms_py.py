"""
Algorithms for CSS Codes as Cohomology: Homological Quantum Error Correction

This module implements the core algorithms for constructing CSS quantum
error-correcting codes from chain complexes and graphs over F₂.

Type-hinted, self-contained implementations.
"""

from __future__ import annotations
import numpy as np
from typing import Optional


def gf2_rref(matrix: np.ndarray) -> tuple[np.ndarray, list[int]]:
    """Compute reduced row echelon form over GF(2).

    Args:
        matrix: Binary matrix (entries in {0, 1}).

    Returns:
        (rref_matrix, pivot_columns): The RREF and list of pivot column indices.
    """
    M = matrix.copy() % 2
    rows, cols = M.shape
    pivots: list[int] = []
    row = 0
    for col in range(cols):
        # Find pivot
        found = None
        for r in range(row, rows):
            if M[r, col] == 1:
                found = r
                break
        if found is None:
            continue
        # Swap
        M[[row, found]] = M[[found, row]]
        pivots.append(col)
        # Eliminate
        for r in range(rows):
            if r != row and M[r, col] == 1:
                M[r] = (M[r] + M[row]) % 2
        row += 1
    return M, pivots


def gf2_kernel(matrix: np.ndarray) -> np.ndarray:
    """Compute a basis for ker(matrix) over GF(2).

    Args:
        matrix: Binary matrix (m x n).

    Returns:
        Basis vectors for the kernel, shape (dim_ker x n).
    """
    M = matrix.copy() % 2
    m, n = M.shape
    # Augment with identity
    aug = np.hstack([M.T, np.eye(n, dtype=int)]) % 2
    rref, pivots = gf2_rref(aug)

    kernel_basis: list[np.ndarray] = []
    for i in range(n):
        if i not in pivots and np.all(rref[i, :m] == 0):
            kernel_basis.append(rref[i, m:])
        elif i >= len(pivots):
            # Free variable
            pass

    # Simpler approach: use null space computation
    rref_M, pivot_cols = gf2_rref(M)
    rank = len(pivot_cols)
    nullity = n - rank

    if nullity == 0:
        return np.zeros((0, n), dtype=int)

    # Build kernel basis from RREF
    free_cols = [j for j in range(n) if j not in pivot_cols]
    basis = np.zeros((nullity, n), dtype=int)
    for idx, fc in enumerate(free_cols):
        basis[idx, fc] = 1
        for i, pc in enumerate(pivot_cols):
            if i < rref_M.shape[0]:
                basis[idx, pc] = rref_M[i, fc]
    return basis % 2


def gf2_rank(matrix: np.ndarray) -> int:
    """Compute the rank of a binary matrix over GF(2).

    Args:
        matrix: Binary matrix.

    Returns:
        Rank over GF(2).
    """
    _, pivots = gf2_rref(matrix % 2)
    return len(pivots)


def hamming_weight(v: np.ndarray) -> int:
    """Compute the Hamming weight (number of nonzero entries mod 2).

    Args:
        v: Binary vector.

    Returns:
        Number of nonzero entries.
    """
    return int(np.sum(v % 2 != 0))


class CSSCode:
    """A Calderbank-Shor-Steane quantum error-correcting code.

    Constructed from two classical codes: codeX (X-stabilizers) and
    codeZ (Z-stabilizers) with codeX ⊆ codeZ (as row spaces).

    Attributes:
        n: Block length (number of physical qubits).
        hx: Parity check matrix for X-stabilizers (rows span codeX).
        hz: Parity check matrix for Z-stabilizers (rows span codeZ).
        k: Number of logical qubits.
    """

    def __init__(self, n: int, hx: np.ndarray, hz: np.ndarray):
        """Initialize a CSS code.

        Args:
            n: Block length.
            hx: Generator matrix for codeX (rows are X-stabilizer generators).
            hz: Generator matrix for codeZ (rows are Z-stabilizer generators).
        """
        self.n = n
        self.hx = hx % 2
        self.hz = hz % 2

        self.dim_x = gf2_rank(self.hx) if hx.size > 0 else 0
        self.dim_z = gf2_rank(self.hz) if hz.size > 0 else 0
        self.k = self.dim_z - self.dim_x

    def __repr__(self) -> str:
        return f"CSSCode([[{self.n}, {self.k}]])"

    def verify_containment(self) -> bool:
        """Verify that codeX ⊆ codeZ (all X-stabilizers are in Z-stabilizer space)."""
        if self.hx.size == 0:
            return True
        # Check each row of hx is in row space of hz
        combined = np.vstack([self.hz, self.hx]) if self.hz.size > 0 else self.hx
        return gf2_rank(combined) == gf2_rank(self.hz)

    def minimum_distance_estimate(self, max_weight: int = 20) -> Optional[int]:
        """Estimate the minimum distance by searching for low-weight codewords
        in codeZ \\ codeX. This is a brute-force search, exponential in general.

        Args:
            max_weight: Maximum weight to search.

        Returns:
            Minimum weight found, or None if no non-trivial coset representative found.
        """
        ker_z = gf2_kernel(self.hz) if self.hz.size > 0 else np.zeros((0, self.n), dtype=int)
        # Generate coset representatives of codeZ / codeX
        # For small codes only
        if self.dim_z > 15:
            return None

        min_d = self.n + 1
        z_basis = self.hz[:self.dim_z]  # Use first dim_z independent rows

        # Enumerate codeZ elements
        for bits in range(1, 2**self.dim_z):
            coeffs = np.array([(bits >> i) & 1 for i in range(self.dim_z)], dtype=int)
            v = coeffs @ z_basis % 2
            w = hamming_weight(v)

            # Check if v is NOT in codeX
            if self.hx.size > 0:
                combined = np.vstack([self.hx, v.reshape(1, -1)])
                if gf2_rank(combined) == self.dim_x:
                    continue  # v is in codeX
            else:
                if w == 0:
                    continue

            if 0 < w < min_d:
                min_d = w

        return min_d if min_d <= self.n else None


class ChainComplex:
    """A 3-term chain complex C₂ →[∂₂] C₁ →[∂₁] C₀ over GF(2).

    The chain condition ∂₁ ∘ ∂₂ = 0 is verified at construction.

    Attributes:
        d2: Matrix for ∂₂ (dim₁ × dim₂).
        d1: Matrix for ∂₁ (dim₀ × dim₁).
    """

    def __init__(self, d2: np.ndarray, d1: np.ndarray):
        """Initialize a chain complex.

        Args:
            d2: Boundary map ∂₂ as matrix (dim₁ × dim₂).
            d1: Boundary map ∂₁ as matrix (dim₀ × dim₁).
        """
        self.d2 = d2 % 2
        self.d1 = d1 % 2

        # Verify chain condition
        product = (d1 @ d2) % 2
        if not np.all(product == 0):
            raise ValueError("Chain condition ∂₁ ∘ ∂₂ = 0 is violated!")

        self.dim2 = d2.shape[1]
        self.dim1 = d1.shape[1]
        self.dim0 = d1.shape[0]

    def cycles(self) -> np.ndarray:
        """Compute basis for Z₁ = ker(∂₁)."""
        return gf2_kernel(self.d1)

    def boundaries(self) -> np.ndarray:
        """Compute basis for B₁ = im(∂₂)."""
        _, pivots = gf2_rref(self.d2)
        return self.d2[:, :][pivots] if pivots else np.zeros((0, self.dim1), dtype=int)

    def homology_dim(self) -> int:
        """Compute dim H₁ = dim(ker ∂₁) - dim(im ∂₂)."""
        ker_dim = self.dim1 - gf2_rank(self.d1)
        im_dim = gf2_rank(self.d2)
        return ker_dim - im_dim

    def to_css_code(self) -> CSSCode:
        """Construct the CSS code from this chain complex.

        codeX = B₁ = im(∂₂), codeZ = Z₁ = ker(∂₁).
        The CSS code encodes dim(H₁) logical qubits.
        """
        z_basis = self.cycles()
        b_basis_matrix = self.d2.T  # Columns of d2 = image generators

        # Get a proper basis for boundaries
        rref_d2, pivots = gf2_rref(self.d2.T)
        b_basis = rref_d2[:len(pivots)] if pivots else np.zeros((0, self.dim1), dtype=int)

        return CSSCode(self.dim1, b_basis, z_basis)


def graph_boundary_matrix(num_vert: int, edges: list[tuple[int, int]]) -> np.ndarray:
    """Compute the boundary matrix ∂₁ : F₂^E → F₂^V for a graph.

    Args:
        num_vert: Number of vertices.
        edges: List of (source, target) pairs.

    Returns:
        Binary matrix of shape (num_vert, num_edges).
    """
    num_edge = len(edges)
    d1 = np.zeros((num_vert, num_edge), dtype=int)
    for j, (s, t) in enumerate(edges):
        d1[s, j] = (d1[s, j] + 1) % 2
        d1[t, j] = (d1[t, j] + 1) % 2
    return d1


def hypercube_graph(n: int) -> tuple[int, list[tuple[int, int]]]:
    """Construct the n-dimensional hypercube graph Q_n.

    Args:
        n: Dimension of the hypercube.

    Returns:
        (num_vertices, edges): vertex count and edge list.
    """
    num_vert = 2**n
    edges: list[tuple[int, int]] = []
    for v in range(num_vert):
        for bit in range(n):
            w = v ^ (1 << bit)
            if v < w:  # Each edge once
                edges.append((v, w))
    return num_vert, edges


def hqecc_from_graph(num_vert: int, edges: list[tuple[int, int]]) -> CSSCode:
    """Construct an HQECC from a graph.

    The chain complex is 0 →[0] F₂^E →[∂₁] F₂^V,
    so Z₁ = ker(∂₁), B₁ = 0, and the CSS code has k = dim(ker ∂₁).

    For a graph with c connected components:
    k = |E| - |V| + c (the cycle rank / first Betti number).

    Args:
        num_vert: Number of vertices.
        edges: Edge list.

    Returns:
        The CSS code (HQECC).
    """
    d1 = graph_boundary_matrix(num_vert, edges)
    num_edge = len(edges)

    # Z₁ = ker(∂₁)
    z_basis = gf2_kernel(d1)

    # B₁ = 0 (no 2-cells in a graph)
    b_basis = np.zeros((0, num_edge), dtype=int)

    return CSSCode(num_edge, b_basis, z_basis)


def hqecc_from_simplicial_complex(
    num_vert: int,
    edges: list[tuple[int, int]],
    triangles: list[tuple[int, int, int]]
) -> CSSCode:
    """Construct an HQECC from a 2-dimensional simplicial complex.

    Chain complex: F₂^T →[∂₂] F₂^E →[∂₁] F₂^V
    CSS code: codeX = im(∂₂), codeZ = ker(∂₁)
    Logical qubits = dim H₁(K; F₂).

    Args:
        num_vert: Number of vertices.
        edges: List of edges (i, j) with i < j.
        triangles: List of triangles (i, j, k) with i < j < k.

    Returns:
        The CSS code (HQECC).
    """
    num_edge = len(edges)
    num_tri = len(triangles)

    # Build ∂₁ : F₂^E → F₂^V
    d1 = graph_boundary_matrix(num_vert, edges)

    # Build ∂₂ : F₂^T → F₂^E
    # Each triangle (i,j,k) maps to edge(i,j) + edge(j,k) + edge(i,k)
    edge_index = {e: idx for idx, e in enumerate(edges)}

    d2 = np.zeros((num_edge, num_tri), dtype=int)
    for t_idx, (i, j, k) in enumerate(triangles):
        for e in [(i, j), (j, k), (i, k)]:
            e_sorted = (min(e), max(e))
            if e_sorted in edge_index:
                d2[edge_index[e_sorted], t_idx] = (d2[edge_index[e_sorted], t_idx] + 1) % 2

    # Verify chain condition
    product = (d1 @ d2) % 2
    assert np.all(product == 0), "Chain condition violated!"

    cc = ChainComplex(d2, d1)
    return cc.to_css_code()


def quantum_singleton_bound(n: int, k: int, d: int) -> bool:
    """Check if parameters satisfy the quantum Singleton bound: k + 2(d-1) ≤ n.

    Args:
        n: Block length.
        k: Number of logical qubits.
        d: Code distance.

    Returns:
        True if the bound is satisfied.
    """
    return k + 2 * (d - 1) <= n
