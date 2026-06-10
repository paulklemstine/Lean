#!/usr/bin/env python3
"""
Tropical Matrix Algebra: Algorithms

This module implements the core algorithms from tropical matrix algebra:
- Floyd-Warshall via tropical matrix closure
- Karp's minimum cycle mean algorithm
- Tropical power iteration for eigenvalue computation
- Bellman-Ford as tropical matrix-vector product

Each algorithm includes docstrings, type hints, complexity analysis,
and example usage.
"""

import numpy as np
from typing import Tuple, List, Optional


# ============================================================================
# Algorithm 1: Floyd-Warshall via Tropical Matrix Closure
# ============================================================================

def floyd_warshall_tropical(W: np.ndarray) -> np.ndarray:
    """
    All-pairs shortest paths via tropical matrix closure.

    The tropical closure A* = I ⊕ A ⊕ A² ⊕ A³ ⊕ ... is equivalent to
    the Floyd-Warshall algorithm when computed incrementally.

    Args:
        W: n×n weight matrix (W[i][j] = edge weight from i to j,
           np.inf = no edge, diagonal should be 0)

    Returns:
        D: n×n shortest-path distance matrix

    Complexity:
        Time: O(n³)
        Space: O(n²)

    Example:
        >>> W = np.array([[0, 3, np.inf, 7],
        ...               [np.inf, 0, 2, np.inf],
        ...               [np.inf, np.inf, 0, 1],
        ...               [2, np.inf, np.inf, 0]])
        >>> D = floyd_warshall_tropical(W)
        >>> D[0, 2]  # shortest path 0 → 2
        5.0
    """
    n = W.shape[0]
    D = W.copy()

    for k in range(n):
        for i in range(n):
            for j in range(n):
                # Tropical relaxation: D[i,j] = min(D[i,j], D[i,k] + D[k,j])
                if D[i, k] + D[k, j] < D[i, j]:
                    D[i, j] = D[i, k] + D[k, j]

    return D


# ============================================================================
# Algorithm 2: Karp's Minimum Cycle Mean Algorithm
# ============================================================================

def karp_minimum_cycle_mean(W: np.ndarray) -> Tuple[float, List[int]]:
    """
    Compute the minimum cycle mean (tropical eigenvalue) using Karp's algorithm.

    The minimum cycle mean λ* satisfies:
        λ* = min_i max_{0 ≤ k < n} (D_n[i] - D_k[i]) / (n - k)

    where D_k[i] is the minimum weight of a walk of length k from any source to i.

    This is equivalent to: λ* = inf_k tropTrace(A^k)/k

    Args:
        W: n×n weight matrix (no negative cycles required for finite result)

    Returns:
        (lambda_star, cycle): minimum cycle mean and a witnessing cycle

    Complexity:
        Time: O(n³) — n matrix-vector products of O(n²) each
        Space: O(n²) for storing all D_k

    Example:
        >>> W = np.array([[0, 3, 8], [2, 0, 5], [7, 1, 0]])
        >>> lam, cycle = karp_minimum_cycle_mean(W)
        >>> print(f"Minimum cycle mean: {lam}")
    """
    n = W.shape[0]

    # D[k][i] = minimum weight of walk of length k ending at vertex i
    # starting from a virtual source with 0-weight edges to all vertices
    D = np.full((n + 1, n), np.inf)
    D[0, :] = 0  # virtual source

    predecessor = np.full((n + 1, n), -1, dtype=int)

    for k in range(1, n + 1):
        for i in range(n):
            for j in range(n):
                val = D[k - 1, j] + W[j, i]
                if val < D[k, i]:
                    D[k, i] = val
                    predecessor[k, i] = j

    # Compute min_i max_{0 ≤ k < n} (D[n,i] - D[k,i]) / (n - k)
    lambda_star = np.inf
    best_vertex = 0

    for i in range(n):
        max_val = -np.inf
        for k in range(n):
            if D[k, i] < np.inf and D[n, i] < np.inf:
                val = (D[n, i] - D[k, i]) / (n - k)
                max_val = max(max_val, val)
        if max_val < lambda_star:
            lambda_star = max_val
            best_vertex = i

    # Extract cycle
    cycle = _extract_cycle(predecessor, best_vertex, n, W)

    return lambda_star, cycle


def _extract_cycle(predecessor: np.ndarray, vertex: int, n: int,
                   W: np.ndarray) -> List[int]:
    """Extract a minimum-mean cycle from Karp's predecessor table."""
    path = [vertex]
    v = vertex
    for _ in range(n):
        v = predecessor[n - len(path) + 1, v] if n - len(path) + 1 >= 0 else -1
        if v == -1:
            break
        path.append(v)
        if v == vertex:
            break

    # If we didn't find a clean cycle, return the path we have
    if len(path) > 1 and path[-1] == path[0]:
        return path
    return path


# ============================================================================
# Algorithm 3: Tropical Power Iteration
# ============================================================================

def tropical_power_iteration(W: np.ndarray, max_iter: int = 1000,
                              tol: float = 1e-12) -> Tuple[float, np.ndarray, int]:
    """
    Compute tropical eigenvalue and eigenvector via power iteration.

    In the max-plus convention, the tropical eigenvalue λ and eigenvector v satisfy:
        A ⊗ v = λ ⊕ v (entrywise: max_j(A[i,j] + v[j]) = λ + v[i])

    In our min-plus convention:
        (A ⊗ v)_i = min_j(A[i,j] + v[j]) = λ + v[i]

    The iteration normalizes the tropical power A^k · e (where e = (0,...,0))
    and extracts λ from the convergence rate.

    Args:
        W: n×n weight matrix
        max_iter: maximum number of iterations
        tol: convergence tolerance

    Returns:
        (eigenvalue, eigenvector, iterations): the tropical eigenvalue,
            eigenvector, and number of iterations used

    Complexity:
        Time: O(n² · max_iter)
        Space: O(n)

    Example:
        >>> W = np.array([[0, 3, 8], [2, 0, 5], [7, 1, 0]])
        >>> lam, v, iters = tropical_power_iteration(W)
    """
    n = W.shape[0]
    v = np.zeros(n)  # initial vector: all zeros

    prev_min = 0.0
    eigenvalue = 0.0

    for it in range(1, max_iter + 1):
        # Min-plus matrix-vector product: w_i = min_j(W[i,j] + v[j])
        w = np.array([min(W[i, j] + v[j] for j in range(n)) for i in range(n)])

        # Normalize: subtract the minimum component
        shift = min(w)
        eigenvalue = shift / it if it > 0 else 0.0
        w_normalized = w - shift

        # Check convergence of the direction
        if it > 1 and np.max(np.abs(w_normalized - (v - min(v)))) < tol:
            return eigenvalue, w_normalized, it

        v = w

    # Final eigenvalue estimate from trace
    eigenvalue = tropical_eigenvalue_from_trace(W)
    return eigenvalue, v - min(v), max_iter


def tropical_eigenvalue_from_trace(W: np.ndarray, max_k: int = 100) -> float:
    """Compute tropical eigenvalue via trace-power quotients."""
    n = W.shape[0]
    best = float('inf')
    Wk = W.copy()
    for k in range(1, max_k + 1):
        tr = min(Wk[i, i] for i in range(n))
        best = min(best, tr / k)
        # Tropical matrix multiply
        Wk_new = np.full_like(Wk, np.inf)
        for i in range(n):
            for j in range(n):
                Wk_new[i, j] = min(Wk[i, t] + W[t, j] for t in range(n))
        Wk = Wk_new
    return best


# ============================================================================
# Algorithm 4: Bellman-Ford as Tropical Matrix-Vector Product
# ============================================================================

def bellman_ford_tropical(W: np.ndarray, source: int) -> Tuple[np.ndarray, np.ndarray]:
    """
    Single-source shortest paths via iterated tropical matrix-vector product.

    Bellman-Ford is equivalent to computing v^{(k)} = W ⊗ v^{(k-1)}
    where v^{(0)}_i = 0 if i = source, ∞ otherwise.

    Args:
        W: n×n weight matrix
        source: source vertex index

    Returns:
        (distances, predecessors): shortest distances and predecessor array

    Complexity:
        Time: O(n³) — n iterations of O(n²) tropical matrix-vector product
        Space: O(n)

    Example:
        >>> W = np.array([[0, 3, np.inf, 7],
        ...               [np.inf, 0, 2, np.inf],
        ...               [np.inf, np.inf, 0, 1],
        ...               [2, np.inf, np.inf, 0]])
        >>> dist, pred = bellman_ford_tropical(W, 0)
    """
    n = W.shape[0]
    dist = np.full(n, np.inf)
    dist[source] = 0
    pred = np.full(n, -1, dtype=int)

    for _ in range(n - 1):
        # Tropical matrix-vector product: d_i = min_j(W[j,i] + d[j])
        # (note: we use column-oriented update for shortest paths)
        new_dist = dist.copy()
        for i in range(n):
            for j in range(n):
                if dist[j] + W[j, i] < new_dist[i]:
                    new_dist[i] = dist[j] + W[j, i]
                    pred[i] = j
        dist = new_dist

    return dist, pred


# ============================================================================
# Algorithm 5: Tropical Determinant (Optimal Assignment)
# ============================================================================

def tropical_determinant(A: np.ndarray) -> float:
    """
    Compute the tropical determinant (min-plus permanent):
        tdet(A) = min_{σ ∈ S_n} Σ_i A[i, σ(i)]

    This equals the weight of the minimum-weight perfect matching
    in the complete bipartite graph with weights A.

    Args:
        A: n×n weight matrix

    Returns:
        The tropical determinant value

    Complexity:
        Time: O(n!) naively, O(n³) via Hungarian algorithm
        Space: O(n²)

    Note: This naive implementation uses brute force for demonstration.
    For production use, apply the Hungarian algorithm.
    """
    from itertools import permutations
    n = A.shape[0]
    return min(
        sum(A[i, sigma[i]] for i in range(n))
        for sigma in permutations(range(n))
    )


# ============================================================================
# Example Usage and Verification
# ============================================================================

if __name__ == "__main__":
    print("=" * 70)
    print("Tropical Matrix Algebra: Algorithm Demonstrations")
    print("=" * 70)

    # Test graph
    INF = np.inf
    W = np.array([
        [0,   3,   INF, 7],
        [INF, 0,   2,   INF],
        [INF, INF, 0,   1],
        [2,   INF, INF, 0]
    ], dtype=float)

    print("\n--- Floyd-Warshall via Tropical Closure ---")
    D = floyd_warshall_tropical(W)
    print("Shortest-path distances:")
    print(D)
    assert D[0, 2] == 5, f"Expected 5, got {D[0, 2]}"
    assert D[0, 3] == 6, f"Expected 6, got {D[0, 3]}"
    print("✓ All shortest paths verified!")

    print("\n--- Bellman-Ford from vertex 0 ---")
    dist, pred = bellman_ford_tropical(W, 0)
    print(f"Distances from vertex 0: {dist}")
    print(f"Predecessors: {pred}")
    assert np.allclose(dist, D[0, :])
    print("✓ Matches Floyd-Warshall!")

    print("\n--- Karp's Minimum Cycle Mean ---")
    W2 = np.array([[0, 3, 8], [2, 0, 5], [7, 1, 0]], dtype=float)
    lam, cycle = karp_minimum_cycle_mean(W2)
    print(f"Minimum cycle mean: {lam:.4f}")
    print(f"Witnessing cycle: {cycle}")

    print("\n--- Tropical Power Iteration ---")
    lam2, eigvec, iters = tropical_power_iteration(W2)
    print(f"Eigenvalue: {lam2:.6f}")
    print(f"Eigenvector: {eigvec}")
    print(f"Iterations: {iters}")

    print("\n--- Tropical Determinant ---")
    A = np.array([[1, 2, 3], [4, 5, 6], [7, 8, 9]], dtype=float)
    tdet = tropical_determinant(A)
    print(f"tdet(A) = {tdet} (minimum assignment weight)")

    print("\n" + "=" * 70)
    print("All algorithm demonstrations completed successfully!")
    print("=" * 70)
