"""
Tropical Spectral Mechanics — Core Algorithms

Implements Karp's algorithm for computing the minimum cycle mean
(tropical eigenvalue) and related tropical spectral computations.

Author: Tropical Spectral Mechanics Project
"""

import numpy as np
from typing import Tuple, Optional, List


def min_plus_multiply(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """Min-plus matrix multiplication: C[i,j] = min_k (A[i,k] + B[k,j]).

    Args:
        A: n×n matrix with entries in R ∪ {+∞}
        B: n×n matrix with entries in R ∪ {+∞}

    Returns:
        n×n min-plus product matrix
    """
    n = A.shape[0]
    C = np.full((n, n), np.inf)
    for i in range(n):
        for j in range(n):
            C[i, j] = np.min(A[i, :] + B[:, j])
    return C


def min_plus_power(L: np.ndarray, N: int) -> np.ndarray:
    """Compute the N-th min-plus power of matrix L.

    L^{⊕N}[i,j] = minimum cost of a path from i to j using exactly N edges.

    Args:
        L: n×n weight matrix (all entries finite and positive)
        N: number of edges (N ≥ 1)

    Returns:
        n×n matrix of N-step minimum costs
    """
    if N <= 0:
        raise ValueError("N must be positive")
    result = L.copy()
    for _ in range(N - 1):
        result = min_plus_multiply(result, L)
    return result


def karp_min_cycle_mean(L: np.ndarray) -> Tuple[float, List[int]]:
    """Karp's algorithm for minimum cycle mean.

    Computes λ* = min_i max_{0 ≤ k < n} (D[n,i] - D[k,i]) / (n - k)

    where D[k,i] is the minimum cost of a path of length k from a
    virtual source to vertex i.

    This is the tropical eigenvalue of the min-plus matrix L.

    Args:
        L: n×n weight matrix with finite positive entries

    Returns:
        (lambda_star, optimal_cycle): the minimum cycle mean and a
        cycle achieving it

    Time complexity: O(n³)
    Space complexity: O(n²)

    Reference:
        Karp, R.M. "A characterization of the minimum cycle mean in a
        digraph." Discrete Mathematics 23.3 (1978): 309-311.
    """
    n = L.shape[0]

    # D[k][i] = min cost path of exactly k edges ending at i
    # We compute from a virtual source connected to all vertices with cost 0
    D = np.full((n + 1, n), np.inf)
    D[0, :] = 0.0  # virtual source

    for k in range(1, n + 1):
        for i in range(n):
            D[k, i] = np.min(D[k - 1, :] + L[:, i])

    # Karp's formula: λ* = min_i max_{0≤k<n} (D[n,i] - D[k,i]) / (n-k)
    lambda_star = np.inf
    best_vertex = 0

    for i in range(n):
        max_val = -np.inf
        for k in range(n):
            if D[k, i] < np.inf:
                val = (D[n, i] - D[k, i]) / (n - k)
                max_val = max(max_val, val)
        if max_val < lambda_star:
            lambda_star = max_val
            best_vertex = i

    # Reconstruct an optimal cycle (find a cycle achieving λ*)
    optimal_cycle = _find_optimal_cycle(L, lambda_star)

    return lambda_star, optimal_cycle


def _find_optimal_cycle(L: np.ndarray, lambda_star: float) -> List[int]:
    """Find a cycle achieving the minimum cycle mean.

    Args:
        L: weight matrix
        lambda_star: the minimum cycle mean

    Returns:
        List of vertices forming the optimal cycle
    """
    n = L.shape[0]
    # Subtract lambda_star from all edges and look for a zero-mean cycle
    L_shifted = L - lambda_star

    # Find a cycle with non-positive mean in the shifted graph
    # Use Bellman-Ford to detect negative/zero cycles
    dist = np.zeros(n)
    parent = [-1] * n

    for _ in range(n):
        for i in range(n):
            for j in range(n):
                if dist[i] + L_shifted[i, j] < dist[j] - 1e-10:
                    dist[j] = dist[i] + L_shifted[i, j]
                    parent[j] = i

    # Find a vertex on a non-positive cycle
    cycle_vertex = -1
    for i in range(n):
        for j in range(n):
            if dist[i] + L_shifted[i, j] < dist[j] + 1e-10:
                cycle_vertex = j
                break
        if cycle_vertex >= 0:
            break

    if cycle_vertex < 0:
        return [0]  # fallback

    # Trace back to find the cycle
    visited = set()
    v = cycle_vertex
    for _ in range(n):
        v = parent[v] if parent[v] >= 0 else v

    # Now v is on the cycle; trace it
    cycle = [v]
    u = parent[v] if parent[v] >= 0 else v
    while u != v:
        cycle.append(u)
        u = parent[u] if parent[u] >= 0 else u
    cycle.reverse()

    return cycle


def tropical_eigenvector(L: np.ndarray) -> Tuple[float, np.ndarray]:
    """Compute the tropical eigenvalue and eigenvector.

    The tropical eigenvector v satisfies:
        min_j (L[i,j] + v[j]) = λ* + v[i]  for all i

    Computed via the Howard (policy iteration) algorithm.

    Args:
        L: n×n weight matrix with positive finite entries

    Returns:
        (lambda_star, v): eigenvalue and eigenvector (normalized so v[0] = 0)

    Time complexity: O(n³) worst case, typically much faster
    """
    n = L.shape[0]
    lambda_star, _ = karp_min_cycle_mean(L)

    # Solve the fixed-point equation via value iteration
    # v^{k+1}[i] = min_j (L[i,j] + v^k[j]) - λ*
    v = np.zeros(n)
    for _ in range(n * n):  # sufficient iterations for convergence
        v_new = np.array([np.min(L[i, :] + v) - lambda_star for i in range(n)])
        v_new -= v_new[0]  # normalize
        if np.max(np.abs(v_new - v)) < 1e-12:
            break
        v = v_new

    return lambda_star, v


def tropical_spectral_gap(L: np.ndarray) -> float:
    """Compute the tropical spectral gap.

    The spectral gap γ is the difference between the second-smallest
    and smallest cycle means. It governs the exponential convergence
    rate of the value function.

    Args:
        L: n×n weight matrix

    Returns:
        The spectral gap γ ≥ 0
    """
    n = L.shape[0]
    lambda_star, _ = karp_min_cycle_mean(L)

    # Compute all cycle means
    cycle_means = set()
    for length in range(1, n + 1):
        Lk = min_plus_power(L, length)
        for i in range(n):
            mean = Lk[i, i] / length
            cycle_means.add(round(mean, 12))  # round to avoid floating point issues

    sorted_means = sorted(cycle_means)
    if len(sorted_means) <= 1:
        return 0.0

    return sorted_means[1] - sorted_means[0]


def value_function(L: np.ndarray, N: int, q0: int, qf: int) -> float:
    """Compute V(N, q0, qf): minimum cost of a path from q0 to qf in N steps.

    Args:
        L: n×n weight matrix
        N: number of steps (edges)
        q0: starting vertex
        qf: ending vertex

    Returns:
        Minimum path cost
    """
    if N <= 0:
        return 0.0 if q0 == qf else np.inf

    LN = min_plus_power(L, N)
    return LN[q0, qf]


def verify_eigenpair(L: np.ndarray, lam: float, v: np.ndarray, tol: float = 1e-8) -> bool:
    """Verify that (λ, v) is a tropical eigenpair.

    Checks: min_j (L[i,j] + v[j]) = λ + v[i] for all i.

    Args:
        L: weight matrix
        lam: proposed eigenvalue
        v: proposed eigenvector
        tol: tolerance for floating-point comparison

    Returns:
        True if (λ, v) is a valid eigenpair within tolerance
    """
    n = L.shape[0]
    for i in range(n):
        lhs = np.min(L[i, :] + v)
        rhs = lam + v[i]
        if abs(lhs - rhs) > tol:
            return False
    return True


if __name__ == "__main__":
    # Example: 3-vertex system
    print("=" * 60)
    print("Tropical Spectral Mechanics — Algorithm Demo")
    print("=" * 60)

    # Simple 3-vertex system
    L = np.array([
        [3.0, 1.0, 2.0],
        [2.0, 3.0, 1.0],
        [1.0, 2.0, 3.0]
    ])

    print(f"\nLagrangian matrix L:\n{L}")

    # Compute tropical eigenvalue
    lam, cycle = karp_min_cycle_mean(L)
    print(f"\nTropical eigenvalue (min cycle mean): λ* = {lam:.6f}")
    print(f"Optimal cycle: {cycle}")

    # Compute eigenvector
    lam2, v = tropical_eigenvector(L)
    print(f"\nTropical eigenvector: v = {v}")
    print(f"Eigenpair verified: {verify_eigenpair(L, lam2, v)}")

    # Spectral gap
    gap = tropical_spectral_gap(L)
    print(f"\nTropical spectral gap: γ = {gap:.6f}")

    # Value function convergence
    print(f"\nValue function convergence (q0=0):")
    print(f"{'N':>4} {'V(N,0,0)':>12} {'V/N':>12} {'V - N*λ*':>12}")
    for N in range(1, 21):
        V = value_function(L, N, 0, 0)
        print(f"{N:4d} {V:12.4f} {V/N:12.6f} {V - N*lam:12.6f}")
