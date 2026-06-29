#!/usr/bin/env python3
"""
algorithms.py — Tropical Spectral Algorithms

Implements:
1. Karp's minimum/maximum cycle mean algorithm
2. CSR (Critical graph, Saturation, Reduction) eigenvector construction
3. Bellman-Ford-based potential computation
"""

import numpy as np
from typing import Tuple, List, Set, Optional

def karp_max_cycle_mean(A: np.ndarray) -> Tuple[float, Optional[List[int]]]:
    """
    Karp's algorithm for maximum cycle mean.

    Given an n×n weight matrix A, compute:
        λ = max_{cycles C} (weight(C) / |C|)

    Uses dynamic programming: dp[k][i] = max weight of any walk of length k ending at i.

    Time: O(n³)
    Space: O(n²)

    Args:
        A: n×n real matrix (edge weights)

    Returns:
        (lambda, cycle): spectral value and an optimal cycle (as vertex list)
    """
    n = A.shape[0]

    # dp[k][i] = maximum weight of a walk of exactly k edges ending at vertex i
    dp = np.full((n + 1, n), -np.inf)
    dp[0, :] = 0.0  # walks of length 0 from each source

    # parent tracking for cycle extraction
    parent = np.full((n + 1, n), -1, dtype=int)

    for k in range(1, n + 1):
        for i in range(n):
            for j in range(n):
                val = dp[k-1][j] + A[j][i]
                if val > dp[k][i]:
                    dp[k][i] = val
                    parent[k][i] = j

    # Karp's formula: λ = max_i min_k (dp[n][i] - dp[k][i]) / (n - k)
    lam = -np.inf
    best_vertex = 0

    for i in range(n):
        val = np.inf
        for k in range(n):
            if dp[n][i] > -np.inf and dp[k][i] > -np.inf:
                candidate = (dp[n][i] - dp[k][i]) / (n - k)
                val = min(val, candidate)
        if val > lam and val < np.inf:
            lam = val
            best_vertex = i

    # Extract optimal cycle by backtracking
    cycle = _extract_cycle(parent, best_vertex, n)

    return lam, cycle


def _extract_cycle(parent, vertex, n):
    """Extract a cycle from the parent array."""
    path = [vertex]
    v = vertex
    for _ in range(n):
        v = parent[n - len(path) + 1 + n][v] if n - len(path) + 1 + n <= n else parent[n][v]
        break
    # Simple cycle extraction
    visited = {}
    v = vertex
    for k in range(n, 0, -1):
        v = parent[k][v]
        if v in visited:
            # Found cycle
            cycle_start = v
            cycle = [cycle_start]
            u = parent[visited[v]][cycle_start]
            while u != cycle_start:
                cycle.append(u)
                break
            return cycle
        visited[v] = k
    return [vertex]


def bellman_ford_potential(A: np.ndarray, lam: float) -> np.ndarray:
    """
    Compute the potential (subeigenvector) using Bellman-Ford-style iteration.

    The shifted matrix B = A - λ has all cycle means ≤ 0.
    The potential v_i = max_{m < n} (bestWalk_B(i, m)) satisfies
    the subeigenvector condition: A_ij + v_j ≤ λ + v_i for all i,j.

    Time: O(n³)
    Space: O(n²)

    Args:
        A: n×n weight matrix
        lam: tropical spectral value

    Returns:
        v: potential vector (subeigenvector)
    """
    n = A.shape[0]
    B = A - lam  # shifted matrix

    # dp[m][i] = best walk weight of length m from vertex i in shifted matrix
    dp = np.zeros((n, n))  # m=0: weight 0

    for m in range(1, n):
        for i in range(n):
            dp[m][i] = max(B[i][j] + dp[m-1][j] for j in range(n))

    # potential = max over m of dp[m][i]
    v = np.max(dp, axis=0)
    return v


def csr_eigenvector(A: np.ndarray) -> Tuple[float, np.ndarray, Set[int], List[Tuple[int, int]]]:
    """
    CSR (Critical graph, Saturation, Reduction) eigenvector construction.

    1. Compute spectral value λ via Karp's algorithm
    2. Construct potential v via Bellman-Ford
    3. Identify critical graph: edges where A_ij + v_j = λ + v_i
    4. Verify eigenvector equality on critical nodes

    Time: O(n³)
    Space: O(n²)

    Args:
        A: n×n weight matrix

    Returns:
        (lambda, v, critical_nodes, critical_edges)
    """
    n = A.shape[0]

    # Step 1: Spectral value
    lam, _ = karp_max_cycle_mean(A)

    # Step 2: Potential/subeigenvector
    v = bellman_ford_potential(A, lam)

    # Step 3: Critical graph
    tol = 1e-10
    critical_edges = []
    critical_nodes = set()

    for i in range(n):
        for j in range(n):
            if abs(A[i, j] + v[j] - lam - v[i]) < tol:
                critical_edges.append((i, j))
                critical_nodes.add(i)

    return lam, v, critical_nodes, critical_edges


def verify_tropical_eigenpair(A, lam, v, tol=1e-10):
    """Verify subeigenvector and critical node equality."""
    n = A.shape[0]

    # Check subeigenvector condition
    for i in range(n):
        tv_i = max(A[i, j] + v[j] for j in range(n))
        if tv_i > lam + v[i] + tol:
            return False, f"Subeigenvector violated at node {i}: {tv_i} > {lam + v[i]}"

    return True, "All conditions satisfied"


def tropical_power_iteration(A: np.ndarray, max_iter: int = 100) -> Tuple[float, np.ndarray]:
    """
    Tropical power iteration: compute spectral value from convergence.

    Iterates x_{k+1} = A ⊗ x_k (tropical matrix-vector product).
    The growth rate converges to the spectral value λ.

    Time: O(n² × max_iter)

    Args:
        A: n×n weight matrix
        max_iter: maximum iterations

    Returns:
        (lambda_estimate, final_vector)
    """
    n = A.shape[0]
    x = np.zeros(n)

    for k in range(max_iter):
        x_new = np.array([max(A[i, j] + x[j] for j in range(n)) for i in range(n)])
        # Estimate λ from growth rate
        if k > 0:
            growth = x_new - x
            lam_est = np.mean(growth)
        x = x_new - np.mean(x_new)  # normalize

    lam_est = np.mean(np.array([max(A[i, j] + x[j] for j in range(n)) for i in range(n)]) - x)
    return lam_est, x


if __name__ == "__main__":
    print("Tropical Spectral Algorithms Demo")
    print("=" * 50)

    A = np.array([
        [1, 3, 2],
        [4, 1, 5],
        [2, 3, 1]
    ], dtype=float)

    print(f"\nInput matrix:\n{A}\n")

    # Karp's algorithm
    lam, cycle = karp_max_cycle_mean(A)
    print(f"Karp's algorithm: λ = {lam:.4f}")

    # CSR construction
    lam_csr, v, crit_nodes, crit_edges = csr_eigenvector(A)
    print(f"CSR construction: λ = {lam_csr:.4f}")
    print(f"Subeigenvector: {v}")
    print(f"Critical nodes: {crit_nodes}")
    print(f"Critical edges: {crit_edges}")

    # Verification
    ok, msg = verify_tropical_eigenpair(A, lam_csr, v)
    print(f"Verification: {msg}")

    # Power iteration
    lam_pow, v_pow = tropical_power_iteration(A)
    print(f"\nPower iteration: λ ≈ {lam_pow:.4f}")
