#!/usr/bin/env python3
"""
Algorithms for Systolic Quantum Error Correction

Type-hinted implementations of the core algorithms connecting
systolic geometry to quantum error correction.
"""

from typing import List, Tuple, Optional, Set
import numpy as np
from dataclasses import dataclass


@dataclass
class F2ChainComplex:
    """A 2-dimensional chain complex over F₂.

    Represents C₂ →^{d₂} C₁ →^{d₁} C₀ with d₁∘d₂ = 0.
    All arithmetic is modulo 2.
    """
    d1: np.ndarray  # n₀ × n₁ matrix over F₂
    d2: np.ndarray  # n₁ × n₂ matrix over F₂

    def __post_init__(self) -> None:
        """Verify chain complex condition ∂₁∘∂₂ = 0 mod 2."""
        product = (self.d1 @ self.d2) % 2
        assert np.all(product == 0), "Chain complex condition ∂²=0 violated"

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
    """A CSS quantum error-correcting code over F₂.

    Specified by parity check matrices Hx (X-stabilizers) and Hz (Z-stabilizers)
    satisfying Hz · Hx^T = 0 mod 2.
    """
    n: int          # number of physical qubits
    Hx: np.ndarray  # X-stabilizer parity check matrix
    Hz: np.ndarray  # Z-stabilizer parity check matrix

    def __post_init__(self) -> None:
        """Verify CSS orthogonality."""
        product = (self.Hz @ self.Hx.T) % 2
        assert np.all(product == 0), "CSS orthogonality Hz·Hx^T=0 violated"

    @property
    def rx(self) -> int:
        return self.Hx.shape[0]

    @property
    def rz(self) -> int:
        return self.Hz.shape[0]


def css_from_chain_complex(C: F2ChainComplex) -> CSSCode:
    """Construct a CSS code from a chain complex.

    The fundamental theorem: ∂²=0 implies CSS orthogonality.
    - Hx = ∂₂ᵀ (X-stabilizers from 2-cells)
    - Hz = ∂₁ (Z-stabilizers from 0-cells)
    """
    return CSSCode(
        n=C.n1,
        Hx=C.d2.T.copy(),
        Hz=C.d1.copy()
    )


def hamming_weight(v: np.ndarray) -> int:
    """Compute the Hamming weight of a binary vector."""
    return int(np.count_nonzero(v % 2))


def find_kernel_basis(M: np.ndarray) -> np.ndarray:
    """Find a basis for ker(M) over F₂ using Gaussian elimination."""
    m, n = M.shape
    A = M.copy() % 2
    pivot_cols: List[int] = []
    row = 0
    for col in range(n):
        # Find pivot
        found = False
        for r in range(row, m):
            if A[r, col] == 1:
                A[[row, r]] = A[[r, row]]
                found = True
                break
        if not found:
            continue
        pivot_cols.append(col)
        # Eliminate
        for r in range(m):
            if r != row and A[r, col] == 1:
                A[r] = (A[r] + A[row]) % 2
        row += 1

    # Free variables
    free_cols = [c for c in range(n) if c not in pivot_cols]
    if not free_cols:
        return np.zeros((0, n), dtype=int)

    basis = []
    for fc in free_cols:
        v = np.zeros(n, dtype=int)
        v[fc] = 1
        for i, pc in enumerate(pivot_cols):
            if i < row:
                v[pc] = A[i, fc]
        basis.append(v)
    return np.array(basis, dtype=int) % 2


def compute_code_distance(C: F2ChainComplex) -> Optional[int]:
    """Compute the code distance (systole) of the CSS code from C.

    Returns the minimum Hamming weight of a non-trivial 1-cycle,
    i.e., min{wt(v) : v ∈ ker(∂₁) \\ im(∂₂)}.

    Returns None if all cycles are boundaries (no logical qubits).
    """
    # Find basis of ker(d1) = cycle space
    cycle_basis = find_kernel_basis(C.d1)
    if len(cycle_basis) == 0:
        return None

    # Find basis of im(d2) = boundary space
    # im(d2) = column space of d2 = row space of d2.T
    boundary_basis = find_kernel_basis(
        np.eye(C.n1, dtype=int) - _projection_matrix(C.d2)
    )

    # Check each cycle to see if it's a boundary
    min_dist: Optional[int] = None

    # Enumerate all non-zero vectors in cycle space
    n_cycles = len(cycle_basis)
    for mask in range(1, 2**n_cycles):
        v = np.zeros(C.n1, dtype=int)
        for j in range(n_cycles):
            if mask & (1 << j):
                v = (v + cycle_basis[j]) % 2
        # Check if v is a boundary
        if not _is_in_span(v, C.d2):
            w = hamming_weight(v)
            if min_dist is None or w < min_dist:
                min_dist = w

    return min_dist


def _projection_matrix(M: np.ndarray) -> np.ndarray:
    """Compute projection onto column space of M over F₂."""
    # This is a helper — not exact projection, just checking
    return (M @ np.linalg.pinv(M.astype(float))).round().astype(int) % 2


def _is_in_span(v: np.ndarray, M: np.ndarray) -> bool:
    """Check if v is in the column span of M over F₂."""
    n1, n2 = M.shape
    # Try all linear combinations (exponential but works for small cases)
    for mask in range(2**n2):
        combo = np.zeros(n1, dtype=int)
        for j in range(n2):
            if mask & (1 << j):
                combo = (combo + M[:, j]) % 2
        if np.array_equal(combo, v % 2):
            return True
    return False


def torus_chain_complex(L: int) -> F2ChainComplex:
    """Construct the chain complex for the L×L square torus.

    Vertices: L² (labeled by (i,j) with i,j ∈ {0,...,L-1})
    Edges: 2L² (horizontal and vertical)
    Faces: L² (square faces)

    Returns the F₂ chain complex C₂ →^{d₂} C₁ →^{d₁} C₀.
    """
    n0 = L * L  # vertices
    n1 = 2 * L * L  # edges (L² horizontal + L² vertical)
    n2 = L * L  # faces

    d1 = np.zeros((n0, n1), dtype=int)
    d2 = np.zeros((n1, n2), dtype=int)

    def vidx(i: int, j: int) -> int:
        return (i % L) * L + (j % L)

    def h_edge(i: int, j: int) -> int:
        """Horizontal edge from (i,j) to (i,j+1)."""
        return (i % L) * L + (j % L)

    def v_edge(i: int, j: int) -> int:
        """Vertical edge from (i,j) to (i+1,j)."""
        return L * L + (i % L) * L + (j % L)

    def face(i: int, j: int) -> int:
        return (i % L) * L + (j % L)

    # d1: boundary of edges
    for i in range(L):
        for j in range(L):
            # Horizontal edge (i,j)→(i,j+1): boundary = (i,j+1) - (i,j)
            e = h_edge(i, j)
            d1[vidx(i, j), e] = 1
            d1[vidx(i, (j+1) % L), e] = 1  # mod 2: +1 = -1

            # Vertical edge (i,j)→(i+1,j): boundary = (i+1,j) - (i,j)
            e = v_edge(i, j)
            d1[vidx(i, j), e] = 1
            d1[vidx((i+1) % L, j), e] = 1

    # d2: boundary of faces
    for i in range(L):
        for j in range(L):
            f = face(i, j)
            # Face (i,j) has boundary: h(i,j) + v(i,j+1) + h(i+1,j) + v(i,j)
            d2[h_edge(i, j), f] = 1
            d2[h_edge((i+1) % L, j), f] = 1
            d2[v_edge(i, j), f] = 1
            d2[v_edge(i, (j+1) % L), f] = 1

    d1 = d1 % 2
    d2 = d2 % 2

    return F2ChainComplex(d1=d1, d2=d2)


def dual_complex(C: F2ChainComplex) -> F2ChainComplex:
    """Compute the dual chain complex (swaps vertices and faces)."""
    return F2ChainComplex(d1=C.d2.T.copy(), d2=C.d1.T.copy())


def direct_sum(C1: F2ChainComplex, C2: F2ChainComplex) -> F2ChainComplex:
    """Compute the direct sum of two chain complexes."""
    from scipy.linalg import block_diag
    d1 = block_diag(C1.d1, C2.d1).astype(int) % 2
    d2 = block_diag(C1.d2, C2.d2).astype(int) % 2
    return F2ChainComplex(d1=d1, d2=d2)


def compute_betti_1(C: F2ChainComplex) -> int:
    """Compute the first Betti number β₁ = dim(ker ∂₁) - dim(im ∂₂).

    This equals the number of logical qubits in the CSS code.
    """
    # rank of d1 over F₂
    rank_d1 = _f2_rank(C.d1)
    # rank of d2 over F₂
    rank_d2 = _f2_rank(C.d2)
    # β₁ = n₁ - rank(d1) - rank(d2)
    return C.n1 - rank_d1 - rank_d2


def _f2_rank(M: np.ndarray) -> int:
    """Compute the rank of a matrix over F₂."""
    A = M.copy() % 2
    m, n = A.shape
    row = 0
    for col in range(n):
        found = False
        for r in range(row, m):
            if A[r, col] == 1:
                A[[row, r]] = A[[r, row]]
                found = True
                break
        if not found:
            continue
        for r in range(m):
            if r != row and A[r, col] == 1:
                A[r] = (A[r] + A[row]) % 2
        row += 1
    return row


if __name__ == "__main__":
    # Example: 2×2 torus
    print("=== Torus Chain Complex (L=2) ===")
    C = torus_chain_complex(2)
    print(f"Dimensions: n₀={C.n0}, n₁={C.n1}, n₂={C.n2}")
    print(f"∂₁∘∂₂ = 0: {np.all((C.d1 @ C.d2) % 2 == 0)}")

    beta1 = compute_betti_1(C)
    print(f"β₁ (logical qubits) = {beta1}")

    css = css_from_chain_complex(C)
    print(f"CSS code: [[{css.n}, {beta1}, ?]]")

    dist = compute_code_distance(C)
    print(f"Code distance (systole) = {dist}")
    print(f"Expected: [[8, 2, 2]]")

    # Example: 3×3 torus
    print("\n=== Torus Chain Complex (L=3) ===")
    C3 = torus_chain_complex(3)
    print(f"Dimensions: n₀={C3.n0}, n₁={C3.n1}, n₂={C3.n2}")
    beta1_3 = compute_betti_1(C3)
    print(f"β₁ (logical qubits) = {beta1_3}")
    # Distance computation for L=3 is expensive (2^18 cycles)
    # but feasible
    print(f"Expected: [[18, 2, 3]]")

    # Dual complex
    print("\n=== Dual Complex ===")
    D = dual_complex(C)
    print(f"Dual dimensions: n₀={D.n0}, n₁={D.n1}, n₂={D.n2}")
    print(f"Dual β₁ = {compute_betti_1(D)}")
    print("(Same logical qubits — Poincaré duality)")
