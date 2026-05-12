#!/usr/bin/env python3
"""
Algorithms for Tropical One-Way Rank-Factorization Duality

Implements the core algorithms from the research paper with full type hints
and documentation.
"""

import numpy as np
from typing import Dict, Set, Tuple, Optional, List


def trop_mul(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """
    Tropical (min-plus) matrix multiplication.

    C[i,j] = min_k (A[i,k] + B[k,j])

    Args:
        A: m×r integer matrix
        B: r×n integer matrix

    Returns:
        C: m×n integer matrix (tropical product)

    Complexity: O(m·r·n)

    Example:
        >>> A = np.array([[1, 5], [4, 2]])
        >>> B = np.array([[2, 4], [3, 1]])
        >>> trop_mul(A, B)
        array([[3, 5],
               [5, 3]])
    """
    m, r = A.shape
    _, n = B.shape
    C = np.full((m, n), np.inf)
    for i in range(m):
        for j in range(n):
            for k in range(r):
                C[i, j] = min(C[i, j], A[i, k] + B[k, j])
    return C


def compute_witness_profile(
    A: np.ndarray, B: np.ndarray
) -> Tuple[Dict[Tuple[int, int], Set[int]], Dict[Tuple[int, int], float]]:
    """
    Compute the full witness profile of a tropical factorization.

    For each entry (i,j), compute:
    - W[i,j]: the set of hidden indices achieving the minimum
    - gap[i,j]: the separation gap to the next-best hidden index

    Args:
        A: m×r matrix
        B: r×n matrix

    Returns:
        (witness_sets, gaps): dictionaries indexed by (i,j)

    Complexity: O(m·r·n)
    """
    m, r = A.shape
    _, n = B.shape
    C = trop_mul(A, B)

    witness_sets: Dict[Tuple[int, int], Set[int]] = {}
    gaps: Dict[Tuple[int, int], float] = {}

    for i in range(m):
        for j in range(n):
            vals = [A[i, k] + B[k, j] for k in range(r)]
            min_val = C[i, j]
            W = {k for k in range(r) if abs(vals[k] - min_val) < 1e-10}
            non_witness_excess = [vals[k] - min_val for k in range(r) if k not in W]
            gap = min(non_witness_excess) if non_witness_excess else float('inf')

            witness_sets[(i, j)] = W
            gaps[(i, j)] = gap

    return witness_sets, gaps


def gauge_transform(
    A: np.ndarray, B: np.ndarray, t: np.ndarray
) -> Tuple[np.ndarray, np.ndarray]:
    """
    Apply a gauge transformation.

    A'[i,k] = A[i,k] + t[k]
    B'[k,j] = B[k,j] - t[k]

    The tropical product is invariant: tropMul(A', B') = tropMul(A, B).

    Args:
        A: m×r matrix
        B: r×n matrix
        t: r-vector of gauge shifts

    Returns:
        (A', B'): gauge-transformed matrices
    """
    A_new = A + t[np.newaxis, :]
    B_new = B - t[:, np.newaxis]
    return A_new, B_new


def normalize_factorization(
    A: np.ndarray, B: np.ndarray
) -> Tuple[np.ndarray, np.ndarray]:
    """
    Normalize a factorization so that min_i A[i,k] = 0 for each k.

    This is achieved by the gauge shift t[k] = -min_i A[i,k].

    Args:
        A: m×r matrix
        B: r×n matrix

    Returns:
        (A*, B*): normalized factorization

    Postcondition:
        - A*[i,k] >= 0 for all i,k
        - For each k, exists i such that A*[i,k] = 0
        - tropMul(A*, B*) = tropMul(A, B)
    """
    t = -np.min(A, axis=0)
    return gauge_transform(A, B, t)


def reconstruct_from_profile(
    C: np.ndarray,
    sole_witnesses: Dict[int, Tuple[int, int]],
    r: int
) -> Tuple[np.ndarray, np.ndarray]:
    """
    Reconstruct a normalized factorization from the product C and sole witness data.

    For each hidden index k, sole_witnesses[k] = (i_k, j_k) is an entry where
    k is the unique witness. The reconstruction is:
        A[i,k] = C[i,j_k] - C[i_k,j_k]
        B[k,j] = C[i_k,j]

    Args:
        C: m×n product matrix
        sole_witnesses: mapping from hidden index k to (i_k, j_k)
        r: number of hidden indices

    Returns:
        (A, B): reconstructed factorization

    Complexity: O(r·(m+n))
    """
    m, n = C.shape
    A = np.zeros((m, r))
    B = np.zeros((r, n))

    for k in range(r):
        i_k, j_k = sole_witnesses[k]
        for i in range(m):
            A[i, k] = C[i, j_k] - C[i_k, j_k]
        for j in range(n):
            B[k, j] = C[i_k, j]

    return A, B


def recover_gauge_shift(
    A: np.ndarray, A_prime: np.ndarray,
    B: np.ndarray, B_prime: np.ndarray,
    witness_sets: Dict[Tuple[int, int], Set[int]]
) -> Optional[np.ndarray]:
    """
    Recover the gauge shift t such that A' = A + t and B' = B - t.

    Uses witness entries to extract the shift for each hidden index.

    Args:
        A, A': left factors
        B, B': right factors
        witness_sets: the witness profile

    Returns:
        t: recovered gauge shift, or None if not gauge-equivalent
    """
    r = A.shape[1]
    t = np.zeros(r)
    determined = [False] * r

    for (i, j), W in witness_sets.items():
        for k in W:
            shift = A_prime[i, k] - A[i, k]
            if not determined[k]:
                t[k] = shift
                determined[k] = True
            elif abs(t[k] - shift) > 1e-10:
                return None  # Not gauge-equivalent

    if not all(determined):
        return None

    return t


def check_full_column_witness(
    witness_sets: Dict[Tuple[int, int], Set[int]],
    m: int, r: int, n: int
) -> Dict[int, Optional[int]]:
    """
    Check the full-column witness condition for each hidden index.

    For each k, find a column j₀ where k is a witness at every row.

    Args:
        witness_sets: the witness profile
        m, r, n: matrix dimensions

    Returns:
        Dictionary mapping each k to its full-column witness j₀ (or None)
    """
    result = {}
    for k in range(r):
        found = None
        for j in range(n):
            if all(k in witness_sets.get((i, j), set()) for i in range(m)):
                found = j
                break
        result[k] = found
    return result


if __name__ == "__main__":
    # Quick demo
    np.random.seed(42)
    A = np.random.randint(0, 10, (3, 2)).astype(float)
    B = np.random.randint(0, 10, (2, 4)).astype(float)

    print("A =\n", A.astype(int))
    print("B =\n", B.astype(int))

    C = trop_mul(A, B)
    print("C = tropMul(A, B) =\n", C.astype(int))

    W, gaps = compute_witness_profile(A, B)
    print("\nWitness profile:")
    for (i, j) in sorted(W.keys()):
        print(f"  W({i},{j}) = {W[(i,j)]}  gap = {gaps[(i,j)]:.0f}")

    A_n, B_n = normalize_factorization(A, B)
    print(f"\nNormalized A =\n{A_n.astype(int)}")
    print(f"Normalized B =\n{B_n.astype(int)}")
    print(f"Product preserved: {np.allclose(trop_mul(A_n, B_n), C)}")
