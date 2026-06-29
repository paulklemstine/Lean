"""
Algorithms for Tropical Rank-One Factorization

Implements the recognition, decomposition, and approximation algorithms
from the research paper on tropical rank-1 equivalence.
"""

import numpy as np
from typing import Optional, Tuple, List


def rank_one_decompose(
    A: np.ndarray, tol: float = 1e-10
) -> Optional[Tuple[np.ndarray, np.ndarray]]:
    """
    Algorithm 1: Rank-1 Test and Decomposition (O(nm) time, O(n+m) space).
    
    Given A ∈ ℝ^{n×m}, determines whether A is tropically rank-1
    (additively separable: A[i,j] = p[i] + q[j]) and returns the
    decomposition if so.
    
    Uses the basepoint reconstruction theorem (Theorem 4):
        p[i] = A[i, 0]
        q[j] = A[0, j] - A[0, 0]
    
    Args:
        A: Input matrix of shape (n, m)
        tol: Numerical tolerance for equality checks
        
    Returns:
        (p, q) if A is rank-1, None otherwise.
        
    Complexity:
        Time: O(nm)   Space: O(n + m)
    
    Examples:
        >>> A = np.array([[1, 2, 3], [4, 5, 6]])
        >>> result = rank_one_decompose(A)
        >>> result is not None
        True
        >>> p, q = result
        >>> np.allclose(A, p[:, None] + q[None, :])
        True
    """
    n, m = A.shape
    if n == 0 or m == 0:
        return (np.zeros(n), np.zeros(m))
    
    # Basepoint reconstruction (i0=0, j0=0)
    p = A[:, 0].copy()
    q = A[0, :] - A[0, 0]
    
    # Verify: O(nm) check
    for i in range(n):
        for j in range(m):
            if abs(A[i, j] - p[i] - q[j]) > tol:
                return None
    
    return (p, q)


def find_minor_violation(
    A: np.ndarray, tol: float = 1e-10
) -> Optional[Tuple[int, int, int, int, float]]:
    """
    Find a 2×2 submatrix violating the tropical minor condition.
    
    Returns (i, i', j, j', defect) where
    defect = A[i,j] + A[i',j'] - A[i,j'] - A[i',j] ≠ 0,
    or None if the matrix satisfies the minor condition.
    
    This provides a certificate of non-rank-1 structure.
    
    Complexity: O(nm) using the basepoint method (check reconstruction
    against each entry; the first failure gives the violating rectangle).
    """
    n, m = A.shape
    if n <= 1 or m <= 1:
        return None
    
    p = A[:, 0].copy()
    q = A[0, :] - A[0, 0]
    
    for i in range(n):
        for j in range(m):
            defect = A[i, j] - p[i] - q[j]
            if abs(defect) > tol:
                # The violation is at rectangle (i, 0, j, 0)
                return (i, 0, j, 0, A[i, j] + A[0, 0] - A[i, 0] - A[0, j])
    
    return None


def delta2_matrix(A: np.ndarray) -> np.ndarray:
    """
    Compute the full delta_2 tensor (discrete curvature).
    
    Returns a 4D array D where
    D[i, i', j, j'] = A[i,j] + A[i',j'] - A[i,j'] - A[i',j].
    
    The matrix is rank-1 iff D ≡ 0.
    
    Complexity: O(n²m²) time and space.
    """
    n, m = A.shape
    D = np.zeros((n, n, m, m))
    for i in range(n):
        for i2 in range(n):
            for j in range(m):
                for j2 in range(m):
                    D[i, i2, j, j2] = A[i, j] + A[i2, j2] - A[i, j2] - A[i2, j]
    return D


def best_rank_one_approx_linf(
    A: np.ndarray
) -> Tuple[np.ndarray, np.ndarray, float]:
    """
    Algorithm 2: Best Rank-1 Approximation in L∞ norm.
    
    Tries all base pairs (i0, j0) and returns the one minimizing
    max_{i,j} |A[i,j] - p[i] - q[j]|.
    
    Args:
        A: Input matrix of shape (n, m)
        
    Returns:
        (p, q, error) where error = ‖A - p⊕q‖_∞
        
    Complexity: O(n²m²) (tries all nm base pairs, each costs O(nm) to evaluate)
    """
    n, m = A.shape
    best_err = np.inf
    best_p, best_q = np.zeros(n), np.zeros(m)
    
    for i0 in range(n):
        for j0 in range(m):
            p = A[:, j0].copy()
            q = A[i0, :] - A[i0, j0]
            err = np.max(np.abs(A - p[:, None] - q[None, :]))
            if err < best_err:
                best_err = err
                best_p, best_q = p, q
    
    return best_p, best_q, best_err


def normalize_decomposition(
    p: np.ndarray, q: np.ndarray, i0: int = 0
) -> Tuple[np.ndarray, np.ndarray]:
    """
    Normalize a rank-1 decomposition by fixing the gauge.
    
    Sets p[i0] = 0, which uniquely determines the decomposition
    (by the gauge uniqueness theorem, Theorem 5).
    
    Args:
        p, q: Current decomposition with A = p ⊕ q
        i0: Index to normalize (default: 0)
        
    Returns:
        (p_norm, q_norm) with p_norm[i0] = 0 and A = p_norm ⊕ q_norm
    """
    c = p[i0]
    return p - c, q + c


def tropical_matrix_multiply_minplus(
    U: np.ndarray, V: np.ndarray
) -> np.ndarray:
    """
    Min-plus matrix multiplication: C[i,j] = min_t (U[i,t] + V[t,j]).
    
    This is the tropical semiring product (ℝ, min, +).
    
    Args:
        U: Matrix of shape (n, k)
        V: Matrix of shape (k, m)
        
    Returns:
        C: Matrix of shape (n, m) with C[i,j] = min_t(U[i,t] + V[t,j])
    """
    n, k = U.shape
    k2, m = V.shape
    assert k == k2, f"Inner dimensions must match: {k} vs {k2}"
    
    C = np.full((n, m), np.inf)
    for t in range(k):
        C = np.minimum(C, U[:, t:t+1] + V[t:t+1, :])
    return C


def tropical_matrix_multiply_maxplus(
    U: np.ndarray, V: np.ndarray
) -> np.ndarray:
    """
    Max-plus matrix multiplication: C[i,j] = max_t (U[i,t] + V[t,j]).
    
    This is the max-plus tropical semiring product (ℝ, max, +).
    """
    n, k = U.shape
    k2, m = V.shape
    assert k == k2
    
    C = np.full((n, m), -np.inf)
    for t in range(k):
        C = np.maximum(C, U[:, t:t+1] + V[t:t+1, :])
    return C


def verify_minplus_rank_one(
    A: np.ndarray, tol: float = 1e-10
) -> Optional[Tuple[np.ndarray, np.ndarray]]:
    """
    Verify that A has min-plus rank ≤ 1 by finding U (n×1) and V (1×m)
    such that A[i,j] = min_t(U[i,t] + V[t,j]) = U[i,0] + V[0,j].
    
    For rank 1, min-plus and direct sum coincide (Theorem 1).
    """
    result = rank_one_decompose(A, tol)
    if result is None:
        return None
    p, q = result
    U = p.reshape(-1, 1)
    V = q.reshape(1, -1)
    
    # Verify: tropical product equals A
    C = tropical_matrix_multiply_minplus(U, V)
    assert np.allclose(A, C, atol=tol), "Min-plus verification failed"
    return U, V


if __name__ == "__main__":
    print("=== Algorithm Demonstrations ===\n")
    
    # Demo 1: Rank-1 decomposition
    p_true = np.array([1.0, 3.0, -2.0, 0.5])
    q_true = np.array([2.0, -1.0, 4.0, 0.0, 3.5])
    A = p_true[:, None] + q_true[None, :]
    
    print("Input matrix A (rank-1):")
    print(np.round(A, 2))
    
    result = rank_one_decompose(A)
    if result:
        p, q = result
        print(f"\nDecomposition found:")
        print(f"  p = {np.round(p, 4)}")
        print(f"  q = {np.round(q, 4)}")
        
        p_norm, q_norm = normalize_decomposition(p, q)
        print(f"\nNormalized (p[0]=0):")
        print(f"  p = {np.round(p_norm, 4)}")
        print(f"  q = {np.round(q_norm, 4)}")
    
    # Demo 2: Non-rank-1 detection
    B = np.array([[0, 1, 3], [2, 4, 5], [1, 2, 6.0]])
    print(f"\n\nNon-rank-1 matrix B:")
    print(B)
    
    violation = find_minor_violation(B)
    if violation:
        i, i2, j, j2, d = violation
        print(f"Violation at rows ({i},{i2}), cols ({j},{j2}): defect = {d:.4f}")
    
    # Demo 3: Min-plus factorization
    print("\n\nMin-plus rank-1 verification:")
    uv = verify_minplus_rank_one(A)
    if uv:
        U, V = uv
        print(f"  U shape: {U.shape}, V shape: {V.shape}")
        print(f"  U⊗V matches A: {np.allclose(A, tropical_matrix_multiply_minplus(U, V))}")
    
    # Demo 4: Best approximation
    print("\n\nBest rank-1 approximation of non-rank-1 matrix:")
    p_approx, q_approx, err = best_rank_one_approx_linf(B)
    print(f"  L∞ error: {err:.4f}")
    print(f"  p = {np.round(p_approx, 4)}")
    print(f"  q = {np.round(q_approx, 4)}")
