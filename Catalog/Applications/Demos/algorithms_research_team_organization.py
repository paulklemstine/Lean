#!/usr/bin/env python3
"""
Tropical Matrix Iteration: Algorithms

Implements the core algorithms from the tropical dynamics theory:
1. Tropical matrix-vector map (Bellman operator)
2. Tropical matrix multiplication (max-plus)
3. Post/pre-fixed point verification
4. Certified iteration with bounds tracking
5. Tropical eigenvalue approximation via iteration
6. Maximum cycle mean computation
"""

import numpy as np
from typing import Tuple, Optional, List


def tropical_mat_map(A: np.ndarray, x: np.ndarray) -> np.ndarray:
    """
    Tropical (max-plus) matrix-vector map: T(x)_i = max_j (A[i,j] + x[j]).

    This is the Bellman operator for dynamic programming with weight matrix A.

    Time complexity: O(n²) where n = dimension
    Space complexity: O(n)

    Args:
        A: n×n weight matrix (real-valued)
        x: n-dimensional vector

    Returns:
        T(x): n-dimensional vector where T(x)[i] = max_j(A[i,j] + x[j])
    """
    return np.max(A + x[np.newaxis, :], axis=1)


def tropical_mat_mul(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """
    Tropical (max-plus) matrix multiplication: (A⊗B)[i,k] = max_j(A[i,j] + B[j,k]).

    This is NOT standard matrix multiplication — addition becomes max,
    multiplication becomes addition.

    Time complexity: O(n³)
    Space complexity: O(n²)

    Args:
        A: n×n matrix
        B: n×n matrix

    Returns:
        A⊗B: n×n tropical product matrix
    """
    n = A.shape[0]
    C = np.empty((n, n))
    for i in range(n):
        for k in range(n):
            C[i, k] = np.max(A[i, :] + B[:, k])
    return C


def tropical_mat_power(A: np.ndarray, k: int) -> np.ndarray:
    """
    Compute the k-th tropical power A^{⊗k} via repeated squaring.

    Time complexity: O(n³ log k)
    Space complexity: O(n²)
    """
    n = A.shape[0]
    if k == 0:
        # Tropical identity: 0 on diagonal, -∞ elsewhere
        result = np.full((n, n), -np.inf)
        np.fill_diagonal(result, 0.0)
        return result
    if k == 1:
        return A.copy()
    if k % 2 == 0:
        half = tropical_mat_power(A, k // 2)
        return tropical_mat_mul(half, half)
    else:
        return tropical_mat_mul(A, tropical_mat_power(A, k - 1))


def iterate_tropical(A: np.ndarray, x: np.ndarray, k: int) -> np.ndarray:
    """
    Compute T^k(x) by iterating the tropical matrix map k times.

    Time complexity: O(k·n²)
    Space complexity: O(n)
    """
    v = x.copy()
    for _ in range(k):
        v = tropical_mat_map(A, v)
    return v


def iterate_tropical_with_history(
    A: np.ndarray, x: np.ndarray, k: int
) -> List[np.ndarray]:
    """
    Compute T^0(x), T^1(x), ..., T^k(x), returning all intermediate vectors.

    Time complexity: O(k·n²)
    Space complexity: O(k·n)
    """
    history = [x.copy()]
    v = x.copy()
    for _ in range(k):
        v = tropical_mat_map(A, v)
        history.append(v.copy())
    return history


def verify_postfixed(A: np.ndarray, x: np.ndarray, tol: float = 1e-12) -> bool:
    """
    Verify the post-fixed point condition: x ≤ T(x) pointwise.

    If True, the certificate theorem guarantees x ≤ T^k(x) for ALL k ≥ 0.

    Time complexity: O(n²)
    """
    Tx = tropical_mat_map(A, x)
    return bool(np.all(x <= Tx + tol))


def verify_prefixed(A: np.ndarray, x: np.ndarray, tol: float = 1e-12) -> bool:
    """
    Verify the pre-fixed point condition: T(x) ≤ x pointwise.

    If True, the certificate theorem guarantees T^k(x) ≤ x for ALL k ≥ 0.

    Time complexity: O(n²)
    """
    Tx = tropical_mat_map(A, x)
    return bool(np.all(Tx <= x + tol))


def certified_iteration(
    A: np.ndarray,
    x: np.ndarray,
    k: int,
    check_postfixed: bool = True
) -> Tuple[np.ndarray, dict]:
    """
    Certified tropical iteration with automatic bound verification.

    Returns the k-th iterate along with a certificate dict containing:
    - is_postfixed: whether x ≤ T(x) (guarantees x ≤ T^k(x))
    - is_prefixed: whether T(x) ≤ x (guarantees T^k(x) ≤ x)
    - lower_bound: xmin + k*m where m = min(A), xmin = min(x)
    - history: all intermediate iterates

    Time complexity: O(k·n²)
    """
    m = float(np.min(A))
    xmin = float(np.min(x))

    is_post = verify_postfixed(A, x)
    is_pre = verify_prefixed(A, x)

    history = iterate_tropical_with_history(A, x, k)
    result = history[-1]

    cert = {
        "is_postfixed": is_post,
        "is_prefixed": is_pre,
        "lower_bound": xmin + k * m,
        "actual_min": float(np.min(result)),
        "lower_bound_holds": float(np.min(result)) >= xmin + k * m - 1e-12,
        "postfixed_holds": is_post and bool(np.all(x <= result + 1e-12)),
        "prefixed_holds": is_pre and bool(np.all(result <= x + 1e-12)),
        "num_iterations": k,
    }

    return result, cert


def sup_norm_contraction_ratio(
    A: np.ndarray,
    x: np.ndarray,
    y: np.ndarray
) -> float:
    """
    Compute ‖T(x) - T(y)‖∞ / ‖x - y‖∞.

    By the nonexpansiveness theorem, this is always ≤ 1.

    Time complexity: O(n²)
    """
    dist_in = np.max(np.abs(x - y))
    if dist_in < 1e-15:
        return 0.0
    Tx = tropical_mat_map(A, x)
    Ty = tropical_mat_map(A, y)
    dist_out = np.max(np.abs(Tx - Ty))
    return dist_out / dist_in


def maximum_cycle_mean(A: np.ndarray) -> float:
    """
    Compute the maximum cycle mean of the weight matrix A.

    The maximum cycle mean λ* is the tropical eigenvalue:
        max over all cycles (i₁→i₂→...→iₖ→i₁) of
        (A[i₁,i₂] + A[i₂,i₃] + ... + A[iₖ,i₁]) / k

    This is computed using Karp's algorithm: λ* = min_i max_k (D^n[i] - D^k[i])/(n-k)
    where D^k[i] = max weight of a length-k walk ending at i.

    Time complexity: O(n³)
    Space complexity: O(n²)

    Args:
        A: n×n weight matrix

    Returns:
        The maximum cycle mean (tropical eigenvalue)
    """
    n = A.shape[0]
    if n == 0:
        return -np.inf

    # D[k][i] = max weight of a length-k walk ending at i, starting from node 0
    # Actually, for Karp's algorithm we start from all nodes with weight 0
    D = np.full((n + 1, n), -np.inf)
    D[0, :] = 0.0  # Start from all nodes

    for k in range(1, n + 1):
        for i in range(n):
            D[k, i] = np.max(A[:, i] + D[k-1, :])  # max over predecessors

    # Karp's formula: λ* = max_i min_k (D[n,i] - D[k,i]) / (n - k)
    # But we want maximum cycle mean, so:
    lambda_star = -np.inf
    for i in range(n):
        val = np.inf
        for k in range(n):
            if D[k, i] > -np.inf and D[n, i] > -np.inf:
                val = min(val, (D[n, i] - D[k, i]) / (n - k))
        if val < np.inf:
            lambda_star = max(lambda_star, val)

    return lambda_star


def approximate_tropical_eigenvalue(
    A: np.ndarray,
    num_iterations: int = 100
) -> Tuple[float, np.ndarray]:
    """
    Approximate the tropical eigenvalue and eigenvector via power iteration.

    After k iterations, T^k(0)/k → λ (the max cycle mean).
    The normalized iterate converges to an eigenvector.

    Time complexity: O(num_iterations · n²)

    Args:
        A: n×n weight matrix
        num_iterations: number of iterations

    Returns:
        Tuple of (approximate eigenvalue λ, approximate eigenvector v)
    """
    n = A.shape[0]
    v = np.zeros(n)
    for k in range(1, num_iterations + 1):
        v = tropical_mat_map(A, v)

    lam = np.max(v) / num_iterations
    # Normalize to get eigenvector
    eigvec = v - num_iterations * lam
    return lam, eigvec


# ─── Example Usage ───────────────────────────────────────────────────

if __name__ == "__main__":
    print("Tropical Matrix Iteration: Algorithm Demonstrations")
    print("=" * 55)

    # Example matrix
    A = np.array([
        [0.0, 3.0, -1.0],
        [2.0, 0.0,  1.0],
        [1.0, 2.0,  0.0]
    ])

    print(f"\nWeight matrix A:\n{A}\n")

    # Certified iteration
    x = np.zeros(3)
    result, cert = certified_iteration(A, x, k=20)
    print(f"Certified iteration (k=20):")
    print(f"  Result: {result}")
    print(f"  Certificate: {cert}")

    # Maximum cycle mean
    mcm = maximum_cycle_mean(A)
    print(f"\nMaximum cycle mean: {mcm:.4f}")

    # Power iteration eigenvalue
    lam, eigvec = approximate_tropical_eigenvalue(A, 100)
    print(f"Approximate eigenvalue (power iteration): {lam:.4f}")
    print(f"Approximate eigenvector: {eigvec}")

    # Verify eigenvector equation T(v) ≈ v + λ
    Tv = tropical_mat_map(A, eigvec)
    print(f"T(v) - v: {Tv - eigvec}")
    print(f"λ: {lam:.4f}")
    print(f"Max |T(v) - v - λ|: {np.max(np.abs(Tv - eigvec - lam)):.6f}")
