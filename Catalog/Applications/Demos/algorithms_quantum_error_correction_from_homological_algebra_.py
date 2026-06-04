#!/usr/bin/env python3
"""
Algorithms for Homological CSS Code Construction and Analysis

Type-hinted implementations of the core algorithms:
1. GF(2) linear algebra (kernel, rank, row reduction)
2. HomologicalCSSCode construction from chain complexes
3. Systole computation (minimum weight non-trivial cycle)
4. Hypercube and torus complex construction
"""

import numpy as np
from typing import Tuple, List, Optional
from itertools import product as iproduct


def gf2_row_echelon(M: np.ndarray) -> Tuple[np.ndarray, List[int]]:
    """Reduce a matrix over GF(2) to row echelon form.

    Returns:
        (reduced matrix, list of pivot column indices)

    Time complexity: O(m * n * min(m, n)) where M is m x n.
    """
    A = M.copy() % 2
    m, n = A.shape
    pivots: List[int] = []

    for col in range(n):
        # Find pivot in current column
        pivot_row: Optional[int] = None
        for row in range(len(pivots), m):
            if A[row, col] == 1:
                pivot_row = row
                break
        if pivot_row is None:
            continue

        # Swap to pivot position
        A[[len(pivots), pivot_row]] = A[[pivot_row, len(pivots)]]

        # Eliminate below (and above for reduced form)
        for row in range(m):
            if row != len(pivots) and A[row, col] == 1:
                A[row] = (A[row] + A[len(pivots)]) % 2
        pivots.append(col)

    return A, pivots


def gf2_kernel(M: np.ndarray) -> np.ndarray:
    """Compute a basis for ker(M) over GF(2).

    Algorithm: Row-reduce M, identify free variables,
    back-substitute to find kernel vectors.

    Returns:
        Matrix whose rows form a basis for ker(M).
    """
    A, pivots = gf2_row_echelon(M)
    m, n = M.shape
    free_cols = [c for c in range(n) if c not in pivots]

    ker_vecs: List[np.ndarray] = []
    for fc in free_cols:
        v = np.zeros(n, dtype=int)
        v[fc] = 1
        for i, pc in enumerate(pivots):
            v[pc] = A[i, fc]
        ker_vecs.append(v)

    return np.array(ker_vecs, dtype=int) if ker_vecs else np.zeros((0, n), dtype=int)


def gf2_rank(M: np.ndarray) -> int:
    """Rank of M over GF(2)."""
    _, pivots = gf2_row_echelon(M)
    return len(pivots)


def gf2_image_membership(M: np.ndarray, v: np.ndarray) -> bool:
    """Check if v is in the column space of M over GF(2).

    Algorithm: Check if rank([M | v]) = rank(M).
    """
    aug = np.hstack([M, v.reshape(-1, 1)])
    return gf2_rank(M) == gf2_rank(aug)


def compute_systole(d1: np.ndarray, d2: np.ndarray) -> int:
    """Compute the systole (minimum weight non-trivial cycle) of a chain complex.

    A non-trivial cycle is v ∈ ker(d1) \ im(d2).
    The systole is min{wt(v) : v is a non-trivial cycle}.

    WARNING: Exponential time! Only feasible for small n (n ≤ ~25).

    Args:
        d1: m1 x n matrix (boundary map d1)
        d2: n x m2 matrix (boundary map d2)

    Returns:
        Minimum Hamming weight of a non-trivial cycle,
        or n+1 if all cycles are boundaries (β₁ = 0).
    """
    n = d1.shape[1]
    ker_basis = gf2_kernel(d1)
    if ker_basis.shape[0] == 0:
        return n + 1

    min_wt = n + 1
    # Enumerate all non-zero elements of ker(d1)
    for coeffs in iproduct([0, 1], repeat=ker_basis.shape[0]):
        if all(c == 0 for c in coeffs):
            continue
        v = np.zeros(n, dtype=int)
        for c, row in zip(coeffs, ker_basis):
            v = (v + c * row) % 2
        # Check if v is NOT in im(d2)
        if not gf2_image_membership(d2, v):
            wt = int(np.sum(v != 0))
            min_wt = min(min_wt, wt)

    return min_wt


def hypercube_chain_complex(dim: int) -> Tuple[np.ndarray, np.ndarray]:
    """Construct the chain complex of the dim-dimensional hypercube Q_dim.

    The chain complex is: 0 --> GF(2)^edges --d1--> GF(2)^vertices
    (with d2 = 0 since we only use the graph structure).

    Returns:
        (d1, d2) where d1 is vertices x edges incidence matrix,
        d2 is edges x 0 zero matrix.
    """
    num_verts = 2 ** dim
    num_edges = dim * (2 ** (dim - 1))

    d1 = np.zeros((num_verts, num_edges), dtype=int)
    edge_idx = 0
    for bit in range(dim):
        for v in range(num_verts):
            if v & (1 << bit) == 0:
                w = v | (1 << bit)
                d1[v, edge_idx] = 1
                d1[w, edge_idx] = 1
                edge_idx += 1

    d2 = np.zeros((num_edges, 0), dtype=int)
    return d1, d2


def css_code_parameters(d1: np.ndarray, d2: np.ndarray) -> Tuple[int, int, int]:
    """Compute CSS code parameters [[n, k, d]] from a chain complex.

    Args:
        d1: m1 x n boundary map
        d2: n x m2 boundary map

    Returns:
        (n, k, d) where n = physical qubits, k = logical qubits, d = distance
    """
    n = d1.shape[1]
    rank_d1 = gf2_rank(d1)
    rank_d2 = gf2_rank(d2)
    k = n - rank_d1 - rank_d2  # β₁ = nullity(d1) - rank(d2)
    d = compute_systole(d1, d2)
    return n, k, d


def verify_chain_condition(d1: np.ndarray, d2: np.ndarray) -> bool:
    """Verify d1 * d2 = 0 over GF(2)."""
    return np.all((d1 @ d2) % 2 == 0)


def verify_css_orthogonality(d1: np.ndarray, d2: np.ndarray) -> bool:
    """Verify CSS orthogonality: rows of d1 ⊥ columns of d2 over GF(2).

    This should always hold when d1 * d2 = 0 (Theorem 3.1).
    """
    for i in range(d1.shape[0]):
        for j in range(d2.shape[1]):
            if np.sum(d1[i] * d2[:, j]) % 2 != 0:
                return False
    return True


if __name__ == "__main__":
    # Quick test
    print("Testing algorithms...")

    # Repetition code
    d1 = np.array([[1, 1, 0], [0, 1, 1]])
    d2 = np.array([[1], [1], [1]])
    assert verify_chain_condition(d1, d2)
    assert verify_css_orthogonality(d1, d2)
    n, k, d = css_code_parameters(d1, d2)
    print(f"Repetition code: [[{n}, {k}, {d}]]")

    # Hypercube Q3
    d1_q3, d2_q3 = hypercube_chain_complex(3)
    assert verify_chain_condition(d1_q3, d2_q3)
    n, k, d = css_code_parameters(d1_q3, d2_q3)
    print(f"Q3 HQECC: [[{n}, {k}, {d}]]")

    print("All tests passed!")
