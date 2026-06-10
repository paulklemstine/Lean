"""
Algorithms for computing the minimum cycle mean (tropical eigenvalue)
of a weighted directed graph.

Implements:
- Karp's algorithm (O(n^3) time)
- Brute-force enumeration over simple cycles
- Cycle extraction (finding the optimal cycle)
"""

import numpy as np
from itertools import permutations
from typing import Tuple, List, Optional


def karp_min_cycle_mean(W: np.ndarray) -> float:
    """
    Compute the minimum cycle mean using Karp's algorithm.

    Given an n×n weight matrix W, computes:
        λ*(W) = min_v max_{0≤k<n} (d[n][v] - d[k][v]) / (n - k)
    where d[k][v] = min cost of a walk of length exactly k ending at v.

    Parameters
    ----------
    W : np.ndarray
        n×n weight matrix. W[i][j] is the cost of edge i→j.

    Returns
    -------
    float
        The minimum cycle mean (tropical eigenvalue).

    Complexity
    ----------
    Time: O(n³), Space: O(n²)

    Examples
    --------
    >>> W = np.array([[1.0, 2.0], [3.0, 4.0]])
    >>> karp_min_cycle_mean(W)  # min of self-loops and 2-cycle
    1.0
    """
    n = W.shape[0]
    if n == 0:
        return 0.0

    # d[k][v] = minimum cost of a walk of length k ending at v
    # Using a fixed source vertex 0
    INF = float('inf')
    d = np.full((n + 1, n), INF)
    d[0, :] = 0.0  # All-sources version

    for k in range(1, n + 1):
        for v in range(n):
            d[k][v] = min(d[k - 1][u] + W[u][v] for u in range(n))

    # Compute minimum cycle mean
    result = INF
    for v in range(n):
        max_ratio = -INF
        for k in range(n):
            if d[k][v] < INF:
                ratio = (d[n][v] - d[k][v]) / (n - k)
                max_ratio = max(max_ratio, ratio)
        if max_ratio < INF:
            result = min(result, max_ratio)

    return result


def brute_force_min_cycle_mean(W: np.ndarray) -> Tuple[float, List[int]]:
    """
    Compute the minimum cycle mean by enumerating all simple cycles.

    Parameters
    ----------
    W : np.ndarray
        n×n weight matrix.

    Returns
    -------
    Tuple[float, List[int]]
        (minimum cycle mean, optimal cycle as list of vertex indices)

    Complexity
    ----------
    Time: O(n! * n), feasible only for small n (≤ 10).
    """
    n = W.shape[0]
    if n == 0:
        return 0.0, []

    best_mean = float('inf')
    best_cycle: List[int] = []

    # Check all self-loops (length 1)
    for i in range(n):
        mean = W[i][i]
        if mean < best_mean:
            best_mean = mean
            best_cycle = [i]

    # Check all cycles of length 2 to n
    for length in range(2, n + 1):
        for perm in permutations(range(n), length):
            cost = sum(W[perm[i]][perm[(i + 1) % length]] for i in range(length))
            mean = cost / length
            if mean < best_mean:
                best_mean = mean
                best_cycle = list(perm)

    return best_mean, best_cycle


def extract_optimal_cycle(W: np.ndarray) -> Tuple[float, List[int]]:
    """
    Find the optimal cycle achieving the minimum cycle mean.

    Uses Karp's algorithm to compute the value, then backtracks
    to extract the cycle.

    Parameters
    ----------
    W : np.ndarray
        n×n weight matrix.

    Returns
    -------
    Tuple[float, List[int]]
        (minimum cycle mean, optimal cycle vertices)
    """
    n = W.shape[0]
    if n == 0:
        return 0.0, []

    INF = float('inf')
    d = np.full((n + 1, n), INF)
    parent = np.full((n + 1, n), -1, dtype=int)
    d[0, :] = 0.0

    for k in range(1, n + 1):
        for v in range(n):
            for u in range(n):
                cost = d[k - 1][u] + W[u][v]
                if cost < d[k][v]:
                    d[k][v] = cost
                    parent[k][v] = u

    # Find the vertex achieving the minimum cycle mean
    lambda_star = INF
    best_v = 0
    for v in range(n):
        max_ratio = -INF
        for k in range(n):
            if d[k][v] < INF:
                ratio = (d[n][v] - d[k][v]) / (n - k)
                max_ratio = max(max_ratio, ratio)
        if max_ratio < lambda_star:
            lambda_star = max_ratio
            best_v = v

    # Backtrack to find the cycle
    v = best_v
    cycle = []
    for k in range(n, 0, -1):
        cycle.append(v)
        v = parent[k][v]
        if v == -1:
            break

    cycle.reverse()

    # Find the actual cycle (detect loop in the backtrack)
    visited = {}
    actual_cycle = []
    for i, node in enumerate(cycle):
        if node in visited:
            actual_cycle = cycle[visited[node]:i]
            break
        visited[node] = i

    if not actual_cycle:
        actual_cycle = [best_v]

    return lambda_star, actual_cycle


def verify_shift_invariance(W: np.ndarray, a: float, tol: float = 1e-10) -> bool:
    """Verify λ*(W + a) = λ*(W) + a."""
    n = W.shape[0]
    lam_W = karp_min_cycle_mean(W)
    lam_shifted = karp_min_cycle_mean(W + a)
    return abs(lam_shifted - (lam_W + a)) < tol


def verify_monotonicity(W: np.ndarray, W_prime: np.ndarray, tol: float = 1e-10) -> bool:
    """Verify W ≤ W' entrywise ⟹ λ*(W) ≤ λ*(W')."""
    assert np.all(W <= W_prime + tol)
    lam_W = karp_min_cycle_mean(W)
    lam_Wp = karp_min_cycle_mean(W_prime)
    return lam_W <= lam_Wp + tol


if __name__ == "__main__":
    # Example 1: 2x2 matrix
    W = np.array([[5.0, 1.0],
                   [2.0, 6.0]])
    print("=== Example 1: 2x2 matrix ===")
    print(f"W = \n{W}")
    print(f"Karp's algorithm: λ* = {karp_min_cycle_mean(W):.4f}")
    mean, cycle = brute_force_min_cycle_mean(W)
    print(f"Brute force: λ* = {mean:.4f}, cycle = {cycle}")

    # Example 2: 3x3 matrix
    W3 = np.array([[10.0, 1.0, 5.0],
                    [3.0, 10.0, 2.0],
                    [4.0, 6.0, 10.0]])
    print("\n=== Example 2: 3x3 matrix ===")
    print(f"W = \n{W3}")
    print(f"Karp: λ* = {karp_min_cycle_mean(W3):.4f}")
    mean, cycle = brute_force_min_cycle_mean(W3)
    print(f"Brute: λ* = {mean:.4f}, cycle = {cycle}")

    # Example 3: Constant matrix
    W_const = np.full((3, 3), 7.0)
    print(f"\n=== Constant matrix (all 7.0): λ* = {karp_min_cycle_mean(W_const):.4f}")

    # Verify shift invariance
    a = 3.5
    print(f"\n=== Shift invariance test (a={a}) ===")
    print(f"λ*(W) = {karp_min_cycle_mean(W3):.4f}")
    print(f"λ*(W+a) = {karp_min_cycle_mean(W3 + a):.4f}")
    print(f"λ*(W)+a = {karp_min_cycle_mean(W3) + a:.4f}")
    print(f"Shift invariance holds: {verify_shift_invariance(W3, a)}")

    # Verify monotonicity
    W_lower = W3.copy()
    W_upper = W3 + np.abs(np.random.randn(3, 3))
    print(f"\n=== Monotonicity test ===")
    print(f"λ*(W_lower) = {karp_min_cycle_mean(W_lower):.4f}")
    print(f"λ*(W_upper) = {karp_min_cycle_mean(W_upper):.4f}")
    print(f"Monotonicity holds: {verify_monotonicity(W_lower, W_upper)}")
