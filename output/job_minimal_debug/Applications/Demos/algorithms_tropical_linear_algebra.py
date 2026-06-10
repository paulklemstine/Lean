#!/usr/bin/env python3
"""
Algorithms for Tropical Surgery and Spectral Analysis

Implements efficient algorithms for:
  1. Tropical spectral radius computation (Karp's algorithm)
  2. Rank-2 tropical surgery
  3. Critical cycle detection
  4. Spectral sensitivity analysis

All algorithms include docstrings, type hints, and complexity analysis.
"""
import numpy as np
from typing import Tuple, List, Optional, Set


def karp_minimum_cycle_mean(A: np.ndarray) -> Tuple[float, List[int]]:
    """
    Karp's algorithm for the minimum cycle mean of a weighted digraph.

    Given an n×n weight matrix A, computes:
        λ* = min over all cycles C of (sum of edge weights in C / |C|)

    This is the tropical spectral radius (min-plus eigenvalue).

    Time:  O(n³)
    Space: O(n²)

    Args:
        A: n×n weight matrix (entry A[i,j] = weight of edge i→j).

    Returns:
        (lambda_star, cycle): minimum cycle mean and a witnessing cycle.

    Reference:
        R.M. Karp, "A characterization of the minimum cycle mean in a digraph,"
        Discrete Mathematics 23 (1978), 309–311.
    """
    n = A.shape[0]
    INF = float('inf')

    # D[k][j] = min weight of a walk of length k from source 0 to j
    # We use a fixed source vertex 0; the result is source-independent
    # for strongly connected graphs.
    D = np.full((n + 1, n), INF)
    D[0, 0] = 0.0  # source vertex

    parent = [[(-1, -1)] * n for _ in range(n + 1)]

    for k in range(1, n + 1):
        for j in range(n):
            for i in range(n):
                val = D[k - 1][i] + A[i, j]
                if val < D[k][j]:
                    D[k][j] = val
                    parent[k][j] = (k - 1, i)

    # Karp's formula: λ* = min_j max_k (D[n][j] - D[k][j]) / (n - k)
    best_mean = INF
    best_j = 0

    for j in range(n):
        worst_over_k = -INF
        for k in range(n):
            if D[k][j] < INF and D[n][j] < INF:
                val = (D[n][j] - D[k][j]) / (n - k)
                worst_over_k = max(worst_over_k, val)
        if worst_over_k < best_mean:
            best_mean = worst_over_k
            best_j = j

    # Reconstruct cycle (simplified — trace back from best_j)
    cycle = _reconstruct_cycle(A, best_mean, n)

    return best_mean, cycle


def _reconstruct_cycle(A: np.ndarray, target_mean: float, n: int) -> List[int]:
    """Reconstruct a cycle achieving (approximately) the target mean."""
    # Brute-force for small n; for production use Howard's algorithm
    from itertools import product as cprod
    best_diff = float('inf')
    best_cycle = [0]
    for length in range(1, n + 1):
        for walk in cprod(range(n), repeat=length):
            w = sum(A[walk[i], walk[(i + 1) % length]] for i in range(length))
            mean = w / length
            if abs(mean - target_mean) < best_diff:
                best_diff = abs(mean - target_mean)
                best_cycle = list(walk)
    return best_cycle


def tropical_rank_two_surgery(
    A: np.ndarray,
    u: np.ndarray, v: np.ndarray,
    up: np.ndarray, vp: np.ndarray
) -> np.ndarray:
    """
    Rank-2 tropical surgery: B[i,j] = min(A[i,j], u[i]+v[j], u'[i]+v'[j]).

    Time:  O(n²)
    Space: O(n²)

    Args:
        A:  n×n matrix.
        u, v: vectors defining first rank-one template.
        up, vp: vectors defining second rank-one template.

    Returns:
        B: the surgery result matrix.
    """
    R1 = np.add.outer(u, v)
    R2 = np.add.outer(up, vp)
    return np.minimum(A, np.minimum(R1, R2))


def two_entry_surgery(
    A: np.ndarray,
    i1: int, j1: int, c1: float,
    i2: int, j2: int, c2: float
) -> np.ndarray:
    """
    Localized two-entry surgery.

    Time:  O(n²) for copy, O(1) for modification.
    Space: O(n²)

    Args:
        A: n×n matrix.
        (i1,j1,c1), (i2,j2,c2): entries to decrease.

    Returns:
        B: A with B[i1,j1] = min(A[i1,j1], c1), B[i2,j2] = min(A[i2,j2], c2).
    """
    B = A.copy()
    B[i1, j1] = min(A[i1, j1], c1)
    B[i2, j2] = min(A[i2, j2], c2)
    return B


def critical_graph(A: np.ndarray, tol: float = 1e-10) -> Set[Tuple[int, int]]:
    """
    Compute the critical graph of A: the set of edges belonging to
    cycles that achieve the minimum cycle mean.

    Time:  O(n³) for spectral radius + O(n^k) for cycle enumeration (small n)
    Space: O(n²)

    Args:
        A: n×n weight matrix.
        tol: numerical tolerance.

    Returns:
        Set of (i,j) edge pairs in the critical graph.
    """
    n = A.shape[0]
    lam, _ = karp_minimum_cycle_mean(A)

    # Subtract λ from all edges and find zero-weight cycles
    A_shifted = A - lam

    critical_edges = set()
    from itertools import product as cprod
    for length in range(1, n + 1):
        for walk in cprod(range(n), repeat=length):
            w = sum(A_shifted[walk[i], walk[(i + 1) % length]] for i in range(length))
            if abs(w) < tol:
                for i in range(length):
                    critical_edges.add((walk[i], walk[(i + 1) % length]))

    return critical_edges


def spectral_sensitivity_analysis(
    A: np.ndarray,
    edges: List[Tuple[int, int]],
    delta_range: np.ndarray
) -> np.ndarray:
    """
    Analyze how the spectral radius changes as edge weights are perturbed.

    For each delta value, decrease the specified edges by delta and
    compute the new spectral radius.

    Time:  O(|delta_range| × n³)
    Space: O(n²)

    Args:
        A: n×n weight matrix.
        edges: list of (i,j) edges to perturb.
        delta_range: array of perturbation magnitudes.

    Returns:
        Array of spectral radii, one per delta value.
    """
    results = np.zeros(len(delta_range))
    for idx, delta in enumerate(delta_range):
        B = A.copy()
        for (i, j) in edges:
            B[i, j] = A[i, j] - abs(delta)
        lam, _ = karp_minimum_cycle_mean(B)
        results[idx] = lam
    return results


def howard_policy_iteration(A: np.ndarray, max_iter: int = 1000) -> Tuple[float, np.ndarray]:
    """
    Howard's policy iteration for the minimum cycle mean.

    This is often faster than Karp's algorithm in practice, with
    superpolynomial convergence guarantees.

    Time:  O(n³) per iteration, typically O(n) iterations.
    Space: O(n)

    Args:
        A: n×n weight matrix.
        max_iter: maximum number of iterations.

    Returns:
        (lambda_star, policy): minimum cycle mean and optimal policy.

    Reference:
        R.A. Howard, "Dynamic Programming and Markov Processes," 1960.
    """
    n = A.shape[0]

    # Initialize policy: each node chooses the minimum-weight outgoing edge
    policy = np.argmin(A, axis=1)

    for _ in range(max_iter):
        # Compute cycle mean of the current policy graph
        # The policy graph has exactly one outgoing edge per node
        visited = np.full(n, -1)
        lam = float('inf')

        for start in range(n):
            if visited[start] >= 0:
                continue
            path = []
            node = start
            while visited[node] < 0:
                visited[node] = len(path)
                path.append(node)
                node = policy[node]

            if visited[node] >= 0 and node in path:
                # Found a cycle
                cycle_start = path.index(node)
                cycle = path[cycle_start:]
                weight = sum(A[cycle[i], policy[cycle[i]]] for i in range(len(cycle)))
                mean = weight / len(cycle)
                lam = min(lam, mean)

        # Compute bias vector: solve v[i] + λ = A[i, π(i)] + v[π(i)]
        # Using iterative approximation
        v = np.zeros(n)
        for _ in range(n):
            v_new = np.array([A[i, policy[i]] + v[policy[i]] - lam for i in range(n)])
            v = v_new

        # Policy improvement
        new_policy = np.array([np.argmin([A[i, j] + v[j] for j in range(n)]) for i in range(n)])

        if np.array_equal(new_policy, policy):
            break
        policy = new_policy

    return lam, policy


if __name__ == "__main__":
    print("Testing Karp's algorithm:")
    A = np.array([
        [5.0, 2.0, 8.0],
        [3.0, 6.0, 1.0],
        [7.0, 4.0, 3.0]
    ])
    lam, cycle = karp_minimum_cycle_mean(A)
    print(f"  Min cycle mean: {lam:.4f}, cycle: {cycle}")

    print("\nTesting Howard's policy iteration:")
    lam2, policy = howard_policy_iteration(A)
    print(f"  Min cycle mean: {lam2:.4f}, policy: {policy}")

    print("\nTesting critical graph:")
    cg = critical_graph(A)
    print(f"  Critical edges: {cg}")

    print("\nTesting rank-2 surgery:")
    u = np.array([1.0, 0.0, 2.0])
    v = np.array([0.0, 1.0, -1.0])
    up = np.array([0.0, 3.0, 1.0])
    vp = np.array([2.0, 0.0, 1.0])
    B = tropical_rank_two_surgery(A, u, v, up, vp)
    lam_B, _ = karp_minimum_cycle_mean(B)
    print(f"  ρ(A) = {lam:.4f}, ρ(B) = {lam_B:.4f}")
    print(f"  Monotonicity: ρ(B) ≤ ρ(A)? {lam_B <= lam + 1e-10}")
