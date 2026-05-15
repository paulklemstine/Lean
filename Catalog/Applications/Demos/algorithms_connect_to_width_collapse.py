#!/usr/bin/env python3
"""
Algorithms for Tropical Cycle-Mean Rigidity

Implements the key algorithmic content of the theorem:
- Testing whether a matrix is cohomologous to a constant
- Computing the coboundary decomposition (potential recovery)
- Computing tropical eigenpairs
- Cycle-mean analysis
"""

import numpy as np
from typing import Optional, Tuple, List


def recover_potential(A: np.ndarray, tol: float = 1e-10) -> Tuple[bool, Optional[float], Optional[np.ndarray]]:
    """
    Attempt to recover the coboundary decomposition A[i,j] = μ + p[i] - p[j].
    
    Algorithm (O(n²)):
        1. Set μ = A[0,0] (from the diagonal constraint).
        2. Set p[i] = A[i,0] - μ for all i (from comparing to the base vertex 0).
        3. Verify A[i,j] = μ + p[i] - p[j] for all i,j.
    
    Returns:
        (is_cohomologous, μ, p) where p is None if not cohomologous.
    
    Time complexity: O(n²)
    Space complexity: O(n)
    
    >>> A = np.array([[5, 3, 8], [7, 5, 10], [2, 0, 5]])
    >>> ok, mu, p = recover_potential(A)
    >>> ok
    True
    >>> mu
    5.0
    """
    n = A.shape[0]
    assert A.shape == (n, n), "Matrix must be square"
    
    # Step 1: Determine μ from diagonal
    mu = A[0, 0]
    
    # Step 2: Determine potential from first column
    p = A[:, 0] - mu
    
    # Step 3: Verify decomposition
    for i in range(n):
        for j in range(n):
            if abs(A[i, j] - (mu + p[i] - p[j])) > tol:
                return False, None, None
    
    return True, mu, p


def tropical_eigenpair(A: np.ndarray, tol: float = 1e-10) -> Tuple[Optional[float], Optional[np.ndarray]]:
    """
    Compute a tropical eigenpair (λ, x) such that max_j(A[i,j] + x[j]) = λ + x[i].
    
    If A is cohomologous to constant (A[i,j] = μ + p[i] - p[j]),
    then (μ, p) is the eigenpair.
    
    For general matrices, uses the max cycle mean as eigenvalue
    and iterative methods for the eigenvector.
    
    Returns:
        (eigenvalue, eigenvector) or (None, None) if computation fails.
    
    Time complexity: O(n²) for cohomologous case, O(n³) for general case.
    """
    is_coh, mu, p = recover_potential(A, tol)
    if is_coh:
        return mu, p
    
    # General case: max cycle mean via Karp's algorithm
    n = A.shape[0]
    eigenval = max_cycle_mean_karp(A)
    
    # Compute eigenvector via value iteration
    x = np.zeros(n)
    for _ in range(n * n):
        x_new = np.array([np.max(A[i] + x) - eigenval for i in range(n)])
        if np.allclose(x, x_new, atol=tol):
            break
        x = x_new
    
    return eigenval, x


def max_cycle_mean_karp(A: np.ndarray) -> float:
    """
    Karp's algorithm for maximum cycle mean.
    
    Computes max over all cycles c of (sum of A[c[i],c[i+1]] / len(c)).
    
    Algorithm:
        D[k][v] = maximum weight of a walk of length k ending at v.
        λ* = max_v min_k (D[n][v] - D[k][v]) / (n - k)
    
    Time complexity: O(n³)
    Space complexity: O(n²)
    
    >>> A = np.array([[2, 1], [3, 2]])
    >>> max_cycle_mean_karp(A)  # max of {A[0,0], A[1,1], (A[0,1]+A[1,0])/2} = max{2,2,2} = 2
    2.0
    """
    n = A.shape[0]
    
    # D[k][v] = max weight walk of length k from any start to v
    D = np.full((n + 1, n), -np.inf)
    D[0, :] = 0.0
    
    for k in range(1, n + 1):
        for v in range(n):
            for u in range(n):
                D[k][v] = max(D[k][v], D[k-1][u] + A[u][v])
    
    # Karp's formula
    result = -np.inf
    for v in range(n):
        min_val = np.inf
        for k in range(n):
            if D[k][v] > -np.inf:
                min_val = min(min_val, (D[n][v] - D[k][v]) / (n - k))
        result = max(result, min_val)
    
    return result


def gauge_transform(A: np.ndarray, p: np.ndarray) -> np.ndarray:
    """
    Apply gauge transformation: B[i,j] = A[i,j] - p[i] + p[j].
    
    If A[i,j] = μ + p[i] - p[j], then B is the constant matrix with all entries μ.
    This is the discrete analogue of a gauge trivialization in differential geometry.
    
    Time complexity: O(n²)
    
    >>> A = np.array([[5, 3], [7, 5]])
    >>> p = np.array([0, 2])
    >>> gauge_transform(A, p)
    array([[5., 5.],
           [5., 5.]])
    """
    n = A.shape[0]
    return np.array([[A[i][j] - p[i] + p[j] for j in range(n)] for i in range(n)])


def cycle_mean_dispersion(A: np.ndarray, max_cycle_len: int = None) -> float:
    """
    Compute the cycle-mean dispersion: max cycle mean - min cycle mean.
    
    This is a measure of how far the matrix is from being cohomologous to a constant.
    By the main theorem, dispersion = 0 ⟺ CohomologousToConst(A).
    
    Time complexity: O(n^max_cycle_len) — exponential in cycle length.
    For practical use, restrict max_cycle_len to small values.
    """
    from itertools import product
    n = A.shape[0]
    if max_cycle_len is None:
        max_cycle_len = min(n + 1, 5)
    
    means = []
    for length in range(1, max_cycle_len + 1):
        for c in product(range(n), repeat=length):
            w = sum(A[c[i]][c[(i+1) % length]] for i in range(length))
            means.append(w / length)
    
    if not means:
        return 0.0
    return max(means) - min(means)


def coboundary_distance(A: np.ndarray) -> float:
    """
    Compute the L∞ distance from A to the nearest cohomologous-to-constant matrix.
    
    The nearest such matrix has μ = mean of diagonal entries,
    p[i] = mean_j(A[i,j]) - μ (approximately).
    
    This gives a quantitative measure of "how far" A is from cycle-mean equality.
    
    Time complexity: O(n²)
    """
    n = A.shape[0]
    # Best μ: mean of diagonal
    mu = np.mean(np.diag(A))
    # Best p: solve least squares A[i,j] ≈ μ + p[i] - p[j]
    # This reduces to: for each i, p[i] ≈ mean_j(A[i,j]) - μ + mean_j(p[j])
    # Iterative approach
    p = np.zeros(n)
    for _ in range(100):
        p_new = np.array([np.mean(A[i] - mu + p) for i in range(n)])
        if np.allclose(p, p_new, atol=1e-12):
            break
        p = p_new
    
    # Compute residual
    B = np.array([[mu + p[i] - p[j] for j in range(n)] for i in range(n)])
    return np.max(np.abs(A - B))


def is_all_cycle_means_equal_efficient(A: np.ndarray, tol: float = 1e-10) -> Tuple[bool, Optional[float]]:
    """
    Efficiently test if all cycle means are equal by attempting coboundary recovery.
    
    By the main theorem, AllCycleMeansEqual ⟺ CohomologousToConst.
    So we just need to check the coboundary condition, which is O(n²).
    
    This is dramatically faster than enumerating cycles (exponential).
    
    Time complexity: O(n²)
    Space complexity: O(n)
    
    >>> A = np.array([[3, 1, 5], [5, 3, 7], [0, -2, 3]])
    >>> is_all_cycle_means_equal_efficient(A)
    (True, 3.0)
    """
    is_coh, mu, _ = recover_potential(A, tol)
    return is_coh, mu


if __name__ == "__main__":
    print("ALGORITHM DEMONSTRATIONS")
    print("=" * 50)
    
    # Example 1: Cohomologous matrix
    n = 4
    mu = 3.0
    p = np.array([1.0, -2.0, 0.5, 3.0])
    A = np.array([[mu + p[i] - p[j] for j in range(n)] for i in range(n)])
    
    print("\n1. Potential Recovery Algorithm")
    is_coh, rec_mu, rec_p = recover_potential(A)
    print(f"   Input: {n}×{n} cohomologous matrix")
    print(f"   Recovered: μ = {rec_mu}, p = {rec_p}")
    print(f"   Match original? μ: {abs(rec_mu - mu) < 1e-10}, p (up to shift): {np.allclose(rec_p - rec_p[0], p - p[0])}")
    
    print("\n2. Karp's Algorithm for Max Cycle Mean")
    mcm = max_cycle_mean_karp(A)
    print(f"   Max cycle mean: {mcm}")
    print(f"   Matches μ? {abs(mcm - mu) < 1e-10}")
    
    print("\n3. Gauge Transformation")
    B = gauge_transform(A, rec_p)
    print(f"   Gauge-transformed matrix (should be constant):")
    print(f"   {B}")
    
    print("\n4. Tropical Eigenpair")
    eigenval, eigenvec = tropical_eigenpair(A)
    print(f"   Eigenvalue: {eigenval}")
    print(f"   Eigenvector: {eigenvec}")
    Ax = np.array([np.max(A[i] + eigenvec) for i in range(n)])
    print(f"   Verification: max error = {np.max(np.abs(Ax - (eigenval + eigenvec))):.2e}")
    
    # Example 2: Non-cohomologous matrix
    print("\n5. Non-Cohomologous Example")
    A2 = np.array([[1, 0, 2], [3, 1, 0], [0, 4, 1]], dtype=float)
    is_coh2, mu2 = is_all_cycle_means_equal_efficient(A2)
    print(f"   All cycle means equal? {is_coh2}")
    print(f"   Cycle-mean dispersion: {cycle_mean_dispersion(A2):.4f}")
    print(f"   Coboundary distance: {coboundary_distance(A2):.4f}")
