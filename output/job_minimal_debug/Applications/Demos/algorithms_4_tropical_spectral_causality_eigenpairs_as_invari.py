#!/usr/bin/env python3
"""
Algorithms for Tropical Spectral Causality

Implements the core computational tools for tropical spectral analysis
and causal structure verification.
"""

import numpy as np
from typing import Tuple, Optional, List


def trop_mat_vec_mul(A: np.ndarray, v: np.ndarray) -> np.ndarray:
    """
    Min-plus matrix-vector product: (A ⊗ v)(i) = min_k (A(i,k) + v(k)).

    Time complexity: O(n²) where n is the dimension.

    Args:
        A: n×n real matrix (min-plus weights)
        v: n-dimensional real vector

    Returns:
        n-dimensional vector: the min-plus product A ⊗ v
    """
    return np.min(A + v[np.newaxis, :], axis=1)


def trop_mat_mat_mul(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """
    Min-plus matrix-matrix product: (A ⊗ B)(i,j) = min_k (A(i,k) + B(k,j)).

    Time complexity: O(n³).

    Args:
        A, B: n×n real matrices

    Returns:
        n×n matrix: the min-plus product A ⊗ B
    """
    n = A.shape[0]
    result = np.full((n, n), np.inf)
    for i in range(n):
        for j in range(n):
            result[i, j] = np.min(A[i, :] + B[:, j])
    return result


def trop_mat_pow(A: np.ndarray, k: int) -> np.ndarray:
    """
    Tropical matrix power A^⊗k (min-plus iterated product).

    Time complexity: O(n³ · k).

    Args:
        A: n×n real matrix
        k: non-negative integer power

    Returns:
        n×n matrix: A^⊗k (with A^⊗0 = tropical identity)
    """
    n = A.shape[0]
    if k == 0:
        result = np.full((n, n), np.inf)
        np.fill_diagonal(result, 0)
        return result

    result = A.copy()
    for _ in range(k - 1):
        result = trop_mat_mat_mul(result, A)
    return result


def trop_mat_pow_vec(A: np.ndarray, v: np.ndarray, k: int) -> np.ndarray:
    """
    Apply tropical matrix A to vector v, k times: A^⊗k ⊗ v.

    Time complexity: O(n² · k).

    Args:
        A: n×n real matrix
        v: n-dimensional vector
        k: non-negative integer

    Returns:
        n-dimensional vector: A^⊗k ⊗ v
    """
    result = v.copy()
    for _ in range(k):
        result = trop_mat_vec_mul(A, result)
    return result


def karp_min_cycle_mean(A: np.ndarray) -> float:
    """
    Compute the minimum cycle mean (tropical eigenvalue) using Karp's algorithm.

    The minimum cycle mean is:
        λ* = min_{cycles C} (weight(C) / length(C))

    Equivalently, by Karp's theorem:
        λ* = min_i max_{0≤k<n} (d_n(i) - d_k(i)) / (n - k)

    where d_k(i) is the minimum weight k-step walk ending at i.

    Time complexity: O(n³).
    Space complexity: O(n²).

    Args:
        A: n×n real matrix (finite entries required for irreducibility)

    Returns:
        The minimum cycle mean (tropical eigenvalue)
    """
    n = A.shape[0]
    dist = np.full((n + 1, n), np.inf)

    # Use all-sources shortest paths
    for s in range(n):
        dist[0, s] = 0

    for k in range(1, n + 1):
        for i in range(n):
            dist[k, i] = np.min(A[i, :] + dist[k - 1, :])

    min_cycle_mean = np.inf
    for i in range(n):
        max_ratio = -np.inf
        for k in range(n):
            if not np.isinf(dist[k, i]) and not np.isinf(dist[n, i]):
                ratio = (dist[n, i] - dist[k, i]) / (n - k)
                max_ratio = max(max_ratio, ratio)
        if not np.isinf(max_ratio):
            min_cycle_mean = min(min_cycle_mean, max_ratio)

    return min_cycle_mean


def find_tropical_eigenvector(
    A: np.ndarray,
    max_iter: int = 1000,
    tol: float = 1e-12
) -> Tuple[float, np.ndarray]:
    """
    Find a tropical eigenpair (λ, v) satisfying A ⊗ v = v + λ.

    Algorithm: Power iteration in the tropical projective space.
    Starting from v₀ = 0, compute v_{k+1} = A ⊗ v_k - (A ⊗ v_k)[0]
    until convergence.

    Time complexity: O(n² · max_iter).

    Args:
        A: n×n real matrix
        max_iter: maximum number of iterations
        tol: convergence tolerance

    Returns:
        (eigenvalue, eigenvector) tuple
    """
    n = A.shape[0]
    v = np.zeros(n)

    for _ in range(max_iter):
        v_new = trop_mat_vec_mul(A, v)
        d = v_new[0] - v[0]
        v_new_normalized = v_new - d

        if np.max(np.abs(v_new_normalized - v)) < tol:
            v = v_new_normalized
            break
        v = v_new_normalized

    d = trop_mat_vec_mul(A, v)[0] - v[0]
    return d, v


def verify_tropical_eigenpair(
    A: np.ndarray, d: float, v: np.ndarray, tol: float = 1e-10
) -> bool:
    """
    Verify that (d, v) is a tropical eigenpair: A ⊗ v = v + d.

    Args:
        A: n×n matrix
        d: candidate eigenvalue
        v: candidate eigenvector
        tol: tolerance for equality check

    Returns:
        True if the eigenpair condition holds within tolerance
    """
    Av = trop_mat_vec_mul(A, v)
    return np.allclose(Av, v + d, atol=tol)


def tropical_sup_displacement(x: np.ndarray, y: np.ndarray) -> float:
    """
    Sup-norm tropical displacement: d∞(x, y) = max_i |x(i) - y(i)|.

    Args:
        x, y: n-dimensional vectors

    Returns:
        The sup-norm distance
    """
    return np.max(np.abs(x - y))


def tropical_one_sided_displacement(x: np.ndarray, y: np.ndarray) -> float:
    """
    One-sided tropical displacement: d⁺(x, y) = max_i (y(i) - x(i)).

    Args:
        x, y: n-dimensional vectors

    Returns:
        The one-sided displacement
    """
    return np.max(y - x)


def tropical_hilbert_metric(x: np.ndarray, y: np.ndarray) -> float:
    """
    Hilbert projective metric: d_H(x, y) = max_i(x_i - y_i) - min_i(x_i - y_i).

    This is the fundamental metric on tropical projective space.

    Args:
        x, y: n-dimensional vectors (representatives in projective space)

    Returns:
        The Hilbert projective distance
    """
    diff = x - y
    return np.max(diff) - np.min(diff)


def verify_causal_invariance(
    A: np.ndarray, d: float, v: np.ndarray, t_values: np.ndarray
) -> List[Tuple[float, float, bool]]:
    """
    Verify causal invariance along the eigen-ray for multiple t values.

    For each t, checks that d∞(A⊗v, A⊗(v+t)) = |t|.

    Args:
        A: matrix with eigenpair (d, v)
        d: eigenvalue
        v: eigenvector
        t_values: array of shift parameters to test

    Returns:
        List of (t, displacement, is_correct) tuples
    """
    results = []
    for t in t_values:
        Av = trop_mat_vec_mul(A, v)
        Avt = trop_mat_vec_mul(A, v + t)
        disp = tropical_sup_displacement(Av, Avt)
        correct = np.isclose(disp, abs(t))
        results.append((t, disp, correct))
    return results


def verify_iterate_drift(
    A: np.ndarray, d: float, v: np.ndarray, max_k: int = 20
) -> List[Tuple[int, np.ndarray, float, bool]]:
    """
    Verify the iterate drift theorem: A^k ⊗ v = v + k·d.

    Args:
        A: matrix with eigenpair (d, v)
        d: eigenvalue
        v: eigenvector
        max_k: maximum iterate to check

    Returns:
        List of (k, A^k⊗v, max_error, is_correct) tuples
    """
    results = []
    for k in range(max_k + 1):
        Akv = trop_mat_pow_vec(A, v, k)
        expected = v + k * d
        error = np.max(np.abs(Akv - expected))
        correct = np.isclose(error, 0)
        results.append((k, Akv, error, correct))
    return results


def critical_graph(A: np.ndarray, d: float, v: np.ndarray, tol: float = 1e-8) -> List[Tuple[int, int]]:
    """
    Compute the critical graph: edges (i, j) where A(i,j) + v(j) = v(i) + d.

    These are the "tight" edges that achieve the minimum in the eigenpair equation.

    Args:
        A: matrix with eigenpair (d, v)
        d: eigenvalue
        v: eigenvector
        tol: tolerance for equality

    Returns:
        List of (i, j) edges in the critical graph
    """
    n = A.shape[0]
    edges = []
    for i in range(n):
        for j in range(n):
            if abs(A[i, j] + v[j] - (v[i] + d)) < tol:
                edges.append((i, j))
    return edges


if __name__ == "__main__":
    # Example usage
    A = np.array([
        [3, 5, 7],
        [2, 4, 6],
        [1, 3, 5]
    ])

    d, v = find_tropical_eigenvector(A)
    print(f"Eigenvalue: {d}")
    print(f"Eigenvector: {v}")
    print(f"Verified: {verify_tropical_eigenpair(A, d, v)}")

    print(f"\nCritical graph edges: {critical_graph(A, d, v)}")

    print("\nCausal invariance:")
    for t, disp, ok in verify_causal_invariance(A, d, v, np.array([0, 1, 2, 5, -3])):
        print(f"  t={t:6.1f}: displacement={disp:.10f}, |t|={abs(t):.1f}, ok={ok}")

    print("\nIterate drift:")
    for k, Akv, err, ok in verify_iterate_drift(A, d, v, max_k=5):
        print(f"  k={k}: error={err:.2e}, ok={ok}")
