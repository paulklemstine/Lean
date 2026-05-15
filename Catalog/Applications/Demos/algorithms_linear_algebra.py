#!/usr/bin/env python3
"""
Algorithms for Tropical Rank-One Factorization

Implements:
1. Tropical minor verification (O(n²m²) check)
2. Normalized potential extraction (O(nm) construction)
3. Approximate rank-1 projection (find closest rank-1 matrix)
4. Tropical rank detection and certification
"""

import numpy as np
from typing import Tuple, Optional, List


def verify_tropical_rank1(A: np.ndarray, tol: float = 1e-10) -> Tuple[bool, Optional[Tuple]]:
    """
    Verify whether matrix A has tropical rank 1 by checking all 2×2 minors.

    The condition is: A[i1,j1] + A[i2,j2] = A[i1,j2] + A[i2,j1]
    for all pairs of rows (i1,i2) and columns (j1,j2).

    Complexity: O(n² m²) where A is n×m.

    Parameters
    ----------
    A : np.ndarray of shape (n, m)
    tol : float, tolerance for floating-point comparison

    Returns
    -------
    is_rank1 : bool
    witness : None if rank-1, else (i1, i2, j1, j2) counterexample
    """
    n, m = A.shape
    for i1 in range(n):
        for i2 in range(i1 + 1, n):
            for j1 in range(m):
                for j2 in range(j1 + 1, m):
                    diff = (A[i1, j1] + A[i2, j2]) - (A[i1, j2] + A[i2, j1])
                    if abs(diff) > tol:
                        return False, (i1, i2, j1, j2)
    return True, None


def verify_tropical_rank1_fast(A: np.ndarray, tol: float = 1e-10) -> Tuple[bool, Optional[Tuple]]:
    """
    Fast verification using the constant-row-differences criterion.

    If A has tropical rank 1, then A[i,j] - A[i,0] is independent of i.
    We only need to check this for all i and j, which is O(nm).

    Complexity: O(nm) — much faster than the naive O(n²m²) approach.

    Parameters
    ----------
    A : np.ndarray of shape (n, m)
    tol : float

    Returns
    -------
    is_rank1 : bool
    witness : None if rank-1, else (i, j) where row-difference fails
    """
    n, m = A.shape
    if n == 0 or m == 0:
        return True, None

    # Row differences relative to column 0
    ref_diffs = A[0, :] - A[0, 0]  # Reference: row 0

    for i in range(1, n):
        row_diffs = A[i, :] - A[i, 0]
        for j in range(1, m):
            if abs(row_diffs[j] - ref_diffs[j]) > tol:
                return False, (i, j)

    return True, None


def extract_potentials(
    A: np.ndarray, i0: int = 0, j0: int = 0
) -> Tuple[np.ndarray, np.ndarray]:
    """
    Extract normalized row/column potentials from a rank-1 tropical matrix.

    Uses the basepoint construction:
      u(i) = A(i, j0)
      v(j) = A(i0, j) - A(i0, j0)

    Complexity: O(n + m)

    Parameters
    ----------
    A : np.ndarray of shape (n, m)
    i0 : int, base row index
    j0 : int, base column index

    Returns
    -------
    u : np.ndarray of shape (n,)
    v : np.ndarray of shape (m,)
    """
    u = A[:, j0].copy()
    v = A[i0, :] - A[i0, j0]
    return u, v


def project_to_rank1(A: np.ndarray) -> Tuple[np.ndarray, np.ndarray, np.ndarray]:
    """
    Project a matrix to the nearest tropical rank-1 matrix (in Frobenius norm).

    The closest rank-1 tropical matrix A* satisfies A*[i,j] = u[i] + v[j]
    where u and v minimize ||A - (u 1^T + 1 v^T)||_F².

    The optimal solution (up to gauge) is:
      u[i] = mean_j(A[i,j]) - grand_mean(A) / 2  ... actually:
      u[i] = row_mean[i] - grand_mean + col_correction

    More precisely, the optimal u and v satisfy:
      u[i] = (1/m) Σ_j A[i,j] - c
      v[j] = (1/n) Σ_i A[i,j] - c
    where c = (1/(nm)) Σ_{i,j} A[i,j] is chosen so that Σ u[i]/n + Σ v[j]/m = grand mean.

    Complexity: O(nm)

    Parameters
    ----------
    A : np.ndarray of shape (n, m)

    Returns
    -------
    A_proj : np.ndarray, the projected rank-1 matrix
    u : np.ndarray, row potentials
    v : np.ndarray, column potentials
    """
    n, m = A.shape
    row_means = A.mean(axis=1)
    col_means = A.mean(axis=0)
    grand_mean = A.mean()

    u = row_means - grand_mean / 2
    v = col_means - grand_mean / 2

    # Adjust gauge so that u sums to sum of row_means - m * grand_mean / 2
    # Actually, the optimal decomposition is:
    # u[i] = row_means[i] - grand_mean (so Σ u = 0 after centering... no)

    # Correct approach: minimize Σ (A[i,j] - u[i] - v[j])²
    # Taking derivatives: u[i] = row_mean[i] - mean(v)
    #                     v[j] = col_mean[j] - mean(u)
    # Solution: u[i] = row_mean[i] - grand_mean/2, but we need to be careful.
    # The system is: u[i] + mean(v) = row_mean[i]
    #                v[j] + mean(u) = col_mean[j]
    # Let μ_u = mean(u), μ_v = mean(v). Then μ_u + μ_v = grand_mean.
    # Gauge freedom: u → u+c, v → v-c. Fix mean(u) = mean(v) = grand_mean/2.
    # Then u[i] = row_mean[i] - grand_mean/2
    #      v[j] = col_mean[j] - grand_mean/2

    # But actually Σ_j (u[i]+v[j]) = m*u[i] + Σ v[j], so row_mean of A* = u[i] + mean(v).
    # We want u[i] + mean(v) = row_mean[i], so u[i] = row_mean[i] - mean(v).
    # Similarly v[j] = col_mean[j] - mean(u).
    # With gauge: set mean(v) = 0, then u[i] = row_mean[i], v[j] = col_mean[j] - grand_mean.

    u = row_means
    v = col_means - grand_mean

    A_proj = u[:, np.newaxis] + v[np.newaxis, :]
    return A_proj, u, v


def tropical_rank1_residual(A: np.ndarray) -> float:
    """
    Compute the residual of the best rank-1 tropical approximation.

    Returns ||A - A*||_F where A* is the optimal rank-1 projection.

    Complexity: O(nm)
    """
    A_proj, _, _ = project_to_rank1(A)
    return np.linalg.norm(A - A_proj, 'fro')


def gauge_shift(u: np.ndarray, v: np.ndarray, c: float) -> Tuple[np.ndarray, np.ndarray]:
    """
    Apply gauge transformation: u → u + c, v → v - c.

    This preserves the matrix u[i] + v[j] for all i, j.

    Parameters
    ----------
    u, v : potential vectors
    c : gauge constant

    Returns
    -------
    u_new, v_new : shifted potentials
    """
    return u + c, v - c


def normalize_potentials(
    u: np.ndarray, v: np.ndarray, mode: str = "zero_u0"
) -> Tuple[np.ndarray, np.ndarray]:
    """
    Normalize potentials by fixing gauge freedom.

    Modes:
    - "zero_u0": set u[0] = 0 (equivalently, shift by c = -u[0])
    - "zero_v0": set v[0] = 0
    - "zero_mean_u": set mean(u) = 0
    - "zero_mean_v": set mean(v) = 0
    - "balanced": set mean(u) = mean(v) = grand_mean/2

    Complexity: O(n + m)
    """
    if mode == "zero_u0":
        return gauge_shift(u, v, -u[0])
    elif mode == "zero_v0":
        return gauge_shift(u, v, v[0])
    elif mode == "zero_mean_u":
        return gauge_shift(u, v, -np.mean(u))
    elif mode == "zero_mean_v":
        return gauge_shift(u, v, np.mean(v))
    elif mode == "balanced":
        c = (np.mean(v) - np.mean(u)) / 2
        return gauge_shift(u, v, c)
    else:
        raise ValueError(f"Unknown normalization mode: {mode}")


def detect_approximate_rank1(
    A: np.ndarray, threshold: float = 0.01
) -> dict:
    """
    Detect whether a matrix is approximately tropical rank-1.

    Returns a report with:
    - is_rank1: exact rank-1 (up to floating-point tolerance)
    - is_approx_rank1: residual below threshold
    - residual: Frobenius norm of residual
    - relative_residual: residual / ||A||_F
    - potentials: (u, v) if rank-1 or approximately rank-1

    Complexity: O(nm)
    """
    n, m = A.shape
    A_proj, u, v = project_to_rank1(A)
    residual = np.linalg.norm(A - A_proj, 'fro')
    A_norm = np.linalg.norm(A, 'fro')
    rel_residual = residual / A_norm if A_norm > 0 else 0.0

    is_exact, witness = verify_tropical_rank1_fast(A)

    return {
        "is_rank1": is_exact,
        "is_approx_rank1": rel_residual < threshold,
        "residual": residual,
        "relative_residual": rel_residual,
        "potentials": (u, v),
        "projection": A_proj,
        "witness": witness,
    }


# ---- Example usage ----
if __name__ == "__main__":
    print("Tropical Rank-1 Factorization Algorithms")
    print("=" * 50)

    # Example 1: Exact rank-1
    u = np.array([1.0, 2.0, 3.0, 4.0])
    v = np.array([-1.0, 0.0, 2.0])
    A = u[:, None] + v[None, :]

    print("\n--- Exact rank-1 matrix ---")
    print(f"A =\n{A}")
    result = detect_approximate_rank1(A)
    print(f"Exact rank-1: {result['is_rank1']}")
    print(f"Residual: {result['residual']:.2e}")

    # Verify fast algorithm matches slow
    ok_slow, _ = verify_tropical_rank1(A)
    ok_fast, _ = verify_tropical_rank1_fast(A)
    print(f"Slow check: {ok_slow}, Fast check: {ok_fast}")

    # Example 2: Approximate rank-1
    print("\n--- Approximately rank-1 matrix ---")
    np.random.seed(123)
    noise = np.random.randn(4, 3) * 0.01
    A_noisy = A + noise
    result = detect_approximate_rank1(A_noisy)
    print(f"Exact rank-1: {result['is_rank1']}")
    print(f"Approx rank-1: {result['is_approx_rank1']}")
    print(f"Relative residual: {result['relative_residual']:.4f}")

    # Example 3: Not rank-1
    print("\n--- Not rank-1 matrix ---")
    B = np.array([[1, 2, 3], [4, 6, 5], [7, 8, 10]])
    result = detect_approximate_rank1(B)
    print(f"B =\n{B}")
    print(f"Exact rank-1: {result['is_rank1']}")
    print(f"Relative residual: {result['relative_residual']:.4f}")
    print(f"Counterexample at: {result['witness']}")
