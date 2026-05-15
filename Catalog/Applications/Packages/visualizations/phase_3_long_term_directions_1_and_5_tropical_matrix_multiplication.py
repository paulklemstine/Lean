#!/usr/bin/env python3
"""
Tropical Matrix Algebra — Algorithms

Implements the core algorithms from the tropical path algebra framework:
1. Tropical matrix multiplication (O(n³) per multiply)
2. Tropical matrix power (optimal walk weights)
3. Tropical all-pairs longest/shortest paths
4. Boolean reachability via tropical encoding
5. Bellman–Ford style one-step extension
"""

import numpy as np
from typing import List, Tuple, Optional


def tropical_multiply(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """
    Tropical matrix multiplication: C[i,j] = max_k (A[i,k] + B[k,j]).

    Time complexity: O(n³)
    Space complexity: O(n²)

    Parameters
    ----------
    A, B : np.ndarray of shape (n, n)
        Input matrices with real-valued (or -inf) entries.

    Returns
    -------
    C : np.ndarray of shape (n, n)
        The tropical product A ⊗ B.
    """
    n = A.shape[0]
    assert A.shape == (n, n) and B.shape == (n, n), "Matrices must be square and same size"
    # Vectorized: C[i,j] = max_k (A[i,k] + B[k,j])
    # A[:, :, None] has shape (n, n, 1), B[None, :, :] has shape (1, n, n)
    # Sum gives (n, n, n), max over axis 1
    return np.max(A[:, :, np.newaxis] + B[np.newaxis, :, :], axis=1)


def tropical_power(W: np.ndarray, m: int) -> np.ndarray:
    """
    Compute the m-th tropical power of W.

    tropPow W 0 = W (length-1 walks)
    tropPow W m = tropMul(tropPow W (m-1), W) (length-(m+1) walks)

    The entry (i,j) of tropPow(W, m) equals the maximum weight over all
    directed walks of length (m+1) from vertex i to vertex j.

    Time complexity: O(m · n³)
    Space complexity: O(n²)

    Parameters
    ----------
    W : np.ndarray of shape (n, n)
        Weight/adjacency matrix.
    m : int
        Power index (0-indexed: m=0 gives W itself).

    Returns
    -------
    np.ndarray of shape (n, n)
        The m-th tropical power.
    """
    assert m >= 0, "Power must be non-negative"
    result = W.copy()
    for _ in range(m):
        result = tropical_multiply(result, W)
    return result


def tropical_closure(W: np.ndarray, max_length: int) -> np.ndarray:
    """
    Compute the tropical closure: element-wise max of tropPow(W, 0..max_length-1).

    This gives the maximum weight walk of any length up to max_length.
    For shortest paths, negate weights and negate the result.

    Time complexity: O(max_length · n³)

    Parameters
    ----------
    W : np.ndarray of shape (n, n)
    max_length : int
        Maximum walk length to consider.

    Returns
    -------
    np.ndarray of shape (n, n)
        Entry (i,j) = max over m in [1..max_length] of max-weight length-m walk i→j.
    """
    n = W.shape[0]
    best = W.copy()
    current = W.copy()
    for _ in range(1, max_length):
        current = tropical_multiply(current, W)
        best = np.maximum(best, current)
    return best


def bellman_extend(V: np.ndarray, W: np.ndarray) -> np.ndarray:
    """
    Bellman one-step extension: extend optimal walk values by one edge.

    V_new[i,j] = max_k (V[i,k] + W[k,j])

    This is exactly tropical_multiply(V, W), expressed as the Bellman
    recurrence for dynamic programming.

    Time complexity: O(n³)
    """
    return tropical_multiply(V, W)


def encode_boolean_graph(adj: np.ndarray, sentinel: float = -1e18) -> np.ndarray:
    """
    Encode a Boolean adjacency matrix into tropical form.

    True edges → 0 (neutral weight)
    False edges → sentinel (representing -∞)

    Parameters
    ----------
    adj : np.ndarray of bool, shape (n, n)
    sentinel : float
        Value representing "no edge" (should be very negative).

    Returns
    -------
    np.ndarray of shape (n, n)
    """
    return np.where(adj, 0.0, sentinel)


def boolean_reachability(adj: np.ndarray, max_steps: int,
                         sentinel: float = -1e18) -> List[np.ndarray]:
    """
    Compute Boolean reachability matrices for 1..max_steps.

    Returns a list of Boolean matrices where result[m][i,j] is True
    iff there exists a walk of length (m+1) from i to j.

    Time complexity: O(max_steps · n³)

    Parameters
    ----------
    adj : np.ndarray of bool, shape (n, n)
    max_steps : int

    Returns
    -------
    List of np.ndarray of bool, each shape (n, n)
    """
    W = encode_boolean_graph(adj, sentinel)
    results = []
    current = W.copy()
    for _ in range(max_steps):
        results.append(current > sentinel / 2)
        current = tropical_multiply(current, W)
    return results


def find_optimal_walk(W: np.ndarray, length: int, i: int, j: int) -> Tuple[List[int], float]:
    """
    Find the walk of given length from i to j with maximum total weight.

    Uses dynamic programming (Bellman recurrence) with backtracking.

    Time complexity: O(length · n²)
    Space complexity: O(length · n)

    Parameters
    ----------
    W : np.ndarray of shape (n, n)
    length : int
        Walk length (number of edges).
    i, j : int
        Source and target vertices.

    Returns
    -------
    walk : List[int]
        Sequence of vertices in the optimal walk.
    weight : float
        Total weight of the optimal walk.
    """
    n = W.shape[0]

    # Forward pass: compute optimal values
    # dp[t][v] = max weight of a walk of length t from i to v
    dp = [np.full(n, -np.inf) for _ in range(length + 1)]
    parent = [np.full(n, -1, dtype=int) for _ in range(length + 1)]
    dp[0][:] = -np.inf
    dp[0][i] = 0  # length-0 walk (single vertex i)
    # Actually for length-1 walks: dp[1][v] = W[i,v]
    for t in range(1, length + 1):
        for v in range(n):
            for k in range(n):
                val = dp[t - 1][k] + W[k, v]
                if val > dp[t][v]:
                    dp[t][v] = val
                    parent[t][v] = k

    # Backtrack to find the walk
    walk = [j]
    v = j
    for t in range(length, 0, -1):
        v = parent[t][v]
        walk.append(v)
    walk.reverse()

    return walk, dp[length][j]


def tropical_shortest_paths(W: np.ndarray) -> np.ndarray:
    """
    All-pairs shortest paths via tropical algebra.

    Negate weights, compute tropical closure (length up to n-1),
    then negate the result.

    For graphs without negative cycles, this gives exact shortest paths.

    Time complexity: O(n⁴)  [n iterations of O(n³) multiply]

    Parameters
    ----------
    W : np.ndarray of shape (n, n)
        Weight matrix (non-negative weights for standard shortest paths).
        Set W[i,j] = inf for non-edges.

    Returns
    -------
    np.ndarray of shape (n, n)
        Shortest path distances.
    """
    n = W.shape[0]
    # Negate: shortest path = longest path with negated weights
    W_neg = -W
    W_neg[W == np.inf] = -np.inf
    result_neg = tropical_closure(W_neg, n)
    return -result_neg


# ──────────────────────────────────────────────────────────────────
# Example usage
# ──────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("Tropical Matrix Algebra — Algorithm Demonstrations")
    print("=" * 60)

    # Example 1: Tropical multiplication
    A = np.array([[1, 3], [4, 2]], dtype=float)
    B = np.array([[5, -1], [0, 7]], dtype=float)
    C = tropical_multiply(A, B)
    print(f"\nA ⊗ B = \n{C}")
    print(f"Expected: [[6, 10], [9, 9]]")

    # Example 2: Optimal walk finding
    W = np.array([
        [0, 3, -1],
        [2, 0, 5],
        [4, 1, 0]
    ], dtype=float)
    walk, weight = find_optimal_walk(W, 3, 0, 2)
    print(f"\nOptimal length-3 walk from 0 to 2: {walk}, weight = {weight}")

    # Example 3: Boolean reachability on a directed cycle
    adj = np.array([
        [False, True, False],
        [False, False, True],
        [True, False, False]
    ])
    reach = boolean_reachability(adj, 4)
    for m, R in enumerate(reach):
        reachable = {(i, j) for i in range(3) for j in range(3) if R[i, j]}
        print(f"Length-{m+1} reachability: {reachable}")

    print("\nAll algorithm demonstrations complete.")
