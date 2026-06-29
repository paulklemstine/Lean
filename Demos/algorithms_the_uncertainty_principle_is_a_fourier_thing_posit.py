#!/usr/bin/env python3
"""
Algorithms for computing uncertainty bounds for integral transforms.

This module implements:
1. Support-spectral bound computation for DFT
2. Vandermonde transform with support analysis
3. MDS property verification for transform matrices
4. Polynomial root counting (algebraic uncertainty engine)
"""

import numpy as np
from typing import List, Tuple, Optional


def support_indices(v: np.ndarray, tol: float = 1e-10) -> List[int]:
    """Return indices where v is nonzero (above tolerance)."""
    return [int(i) for i in range(len(v)) if abs(v[i]) > tol]


def support_size(v: np.ndarray, tol: float = 1e-10) -> int:
    """Count nonzero entries in a vector."""
    return len(support_indices(v, tol))


def dft_matrix(n: int) -> np.ndarray:
    """
    Construct the n×n DFT matrix.

    M[j,k] = omega^(jk) where omega = e^{2πi/n}.

    Time complexity: O(n²)
    Space complexity: O(n²)
    """
    omega = np.exp(2j * np.pi / n)
    return np.array([[omega ** (j * k) for k in range(n)] for j in range(n)])


def vandermonde_matrix(pts: np.ndarray) -> np.ndarray:
    """
    Construct the Vandermonde matrix V[i,j] = pts[i]^j.

    Args:
        pts: Array of n distinct evaluation points.

    Returns:
        n×n Vandermonde matrix.

    Time complexity: O(n²)
    """
    n = len(pts)
    V = np.ones((n, n), dtype=complex)
    for j in range(1, n):
        V[:, j] = V[:, j-1] * pts
    return V


def compute_uncertainty_product(
    M: np.ndarray,
    f: np.ndarray,
    tol: float = 1e-10
) -> Tuple[int, int, int, int]:
    """
    Compute the support sizes and uncertainty products for a transform.

    Args:
        M: n×n transform matrix
        f: input vector of length n
        tol: tolerance for zero detection

    Returns:
        (supp_f, supp_Mf, sum_bound, prod_bound)
        where sum_bound = supp_f + supp_Mf and prod_bound = supp_f * supp_Mf
    """
    Mf = M @ f
    s_f = support_size(f, tol)
    s_Mf = support_size(Mf, tol)
    return s_f, s_Mf, s_f + s_Mf, s_f * s_Mf


def verify_mds_property(M: np.ndarray, tol: float = 1e-10) -> bool:
    """
    Verify whether a matrix satisfies the MDS property:
    every square submatrix is invertible.

    For an n×n matrix, this requires checking all (n choose k)²
    submatrices for each k from 1 to n.

    WARNING: Exponential time complexity O(2^{2n}). Only feasible for small n.

    Args:
        M: Square matrix to check
        tol: Tolerance for singularity detection

    Returns:
        True if M has the MDS property
    """
    from itertools import combinations
    n = M.shape[0]

    for k in range(1, n + 1):
        for rows in combinations(range(n), k):
            for cols in combinations(range(n), k):
                submatrix = M[np.ix_(list(rows), list(cols))]
                if abs(np.linalg.det(submatrix)) < tol:
                    return False
    return True


def polynomial_root_count(
    coeffs: np.ndarray,
    pts: np.ndarray,
    tol: float = 1e-10
) -> Tuple[int, int]:
    """
    Count roots and nonzero evaluations of a polynomial at given points.

    This implements the algebraic uncertainty engine: the number of roots
    is bounded by the degree, so the number of nonzero evaluations is
    bounded below by n - degree.

    Args:
        coeffs: Polynomial coefficients [a_0, a_1, ..., a_d] (degree d)
        pts: Evaluation points

    Returns:
        (n_roots, n_nonzero) counts of roots and nonzero evaluations
    """
    evals = np.polyval(coeffs[::-1], pts)
    n_roots = int(np.sum(np.abs(evals) < tol))
    n_nonzero = len(pts) - n_roots
    return n_roots, n_nonzero


def degree_evaluation_bound(
    coeffs: np.ndarray,
    pts: np.ndarray,
    tol: float = 1e-10
) -> Tuple[int, int, bool]:
    """
    Verify the degree-evaluation uncertainty principle:
      degree + support_size(evaluations) ≥ n

    Args:
        coeffs: Polynomial coefficients (degree = len(coeffs) - 1)
        pts: n distinct evaluation points

    Returns:
        (degree, eval_support, satisfies_bound)
    """
    degree = len(coeffs) - 1
    evals = np.polyval(coeffs[::-1], pts)
    eval_support = support_size(evals, tol)
    n = len(pts)
    return degree, eval_support, degree + eval_support >= n


def exhaustive_uncertainty_check(
    M: np.ndarray,
    field_size: Optional[int] = None,
    tol: float = 1e-10
) -> Tuple[int, int, int]:
    """
    Exhaustively check the uncertainty principle for all nonzero vectors.

    For real/complex matrices: samples random vectors.
    For finite field size: exhaustively enumerates.

    Args:
        M: n×n transform matrix
        field_size: If given, enumerate over GF(field_size)^n
        tol: Tolerance for zero detection

    Returns:
        (min_sum, min_prod, n_tested)
    """
    n = M.shape[0]
    min_sum = float('inf')
    min_prod = float('inf')
    count = 0

    if field_size is not None:
        # Exhaustive enumeration over finite field
        from itertools import product as cartesian
        for v in cartesian(range(field_size), repeat=n):
            f = np.array(v, dtype=float)
            if np.all(np.abs(f) < tol):
                continue
            Mf = M @ f
            # Reduce modulo field_size
            Mf = np.mod(np.round(Mf).astype(int), field_size).astype(float)
            s_f = support_size(f, tol)
            s_Mf = support_size(Mf, tol)
            min_sum = min(min_sum, s_f + s_Mf)
            min_prod = min(min_prod, s_f * s_Mf)
            count += 1
    else:
        # Random sampling
        for _ in range(10000):
            f = np.random.randn(n) + 1j * np.random.randn(n)
            Mf = M @ f
            s_f = support_size(f, tol)
            s_Mf = support_size(Mf, tol)
            min_sum = min(min_sum, s_f + s_Mf)
            min_prod = min(min_prod, s_f * s_Mf)
            count += 1

    return int(min_sum), int(min_prod), count


if __name__ == "__main__":
    print("Testing MDS property of DFT matrices:")
    for n in [3, 4, 5]:
        M = dft_matrix(n)
        is_mds = verify_mds_property(M, tol=1e-6)
        print(f"  DFT({n}): MDS = {is_mds}")

    print("\nDegree-evaluation uncertainty bounds:")
    pts = np.linspace(0, 1, 10)
    for d in [0, 2, 5, 8]:
        coeffs = np.random.randn(d + 1)
        deg, supp, ok = degree_evaluation_bound(coeffs, pts)
        print(f"  degree={deg}, eval_support={supp}, bound satisfied: {ok}")
