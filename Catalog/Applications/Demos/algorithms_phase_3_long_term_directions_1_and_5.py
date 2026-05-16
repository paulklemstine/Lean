#!/usr/bin/env python3
"""
Tropical Matrix Algebra — Algorithms

Implements the core algorithms from the tropical path algebra formalization:
1. Tropical matrix multiplication (max-plus)
2. Tropical matrix power (iterated)
3. Bellman–Ford via tropical powers
4. All-pairs longest paths
5. Boolean reachability via tropical encoding
"""

from typing import Optional
import numpy as np


# ─────────────────────────────────────────────────────────────────
# Algorithm 1: Tropical Matrix Multiplication
# ─────────────────────────────────────────────────────────────────

def tropical_matmul(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """Tropical (max-plus) matrix multiplication.
    
    Computes C where C[i,j] = max_k (A[i,k] + B[k,j]).
    
    This replaces the standard ring operations:
      - sum → max  (tropical addition)
      - product → +  (tropical multiplication)
    
    Time complexity: O(n³) for n×n matrices.
    Space complexity: O(n²) for the output matrix.
    
    Args:
        A: n×n real matrix
        B: n×n real matrix
    
    Returns:
        n×n matrix C = A ⊗ B in tropical algebra
    
    Example:
        >>> A = np.array([[0, 3], [1, 0]])
        >>> B = np.array([[0, -1], [2, 0]])
        >>> tropical_matmul(A, B)
        array([[5., 3.],
               [2., 0.]])
    """
    n = A.shape[0]
    assert A.shape == B.shape == (n, n), "Matrices must be square and same size"
    
    # Vectorized implementation using broadcasting
    # A[:, :, None] has shape (n, n, 1), B[None, :, :] has shape (1, n, n)
    # Sum gives (n, n, n), then max over axis 1 (the k index)
    return np.max(A[:, :, np.newaxis] + B[np.newaxis, :, :], axis=1)


# ─────────────────────────────────────────────────────────────────
# Algorithm 2: Tropical Matrix Power
# ─────────────────────────────────────────────────────────────────

def tropical_power(W: np.ndarray, m: int) -> np.ndarray:
    """Compute the m-th tropical power of matrix W.
    
    tropPow(W, 0) = W  (length-1 walks)
    tropPow(W, m) = tropMul(tropPow(W, m-1), W)  for m ≥ 1
    
    The (i,j) entry of tropPow(W, m) gives the maximum weight
    of any walk of length (m+1) from vertex i to vertex j.
    
    Time complexity: O(m · n³)
    Space complexity: O(n²)
    
    Args:
        W: n×n weight matrix of a directed graph
        m: power index (0-indexed: m=0 gives W itself)
    
    Returns:
        W^{⊗m}: the m-th tropical power
    """
    assert m >= 0, "Power must be non-negative"
    result = W.copy()
    for _ in range(m):
        result = tropical_matmul(result, W)
    return result


# ─────────────────────────────────────────────────────────────────
# Algorithm 3: All-Pairs Longest Paths (via Tropical Powers)
# ─────────────────────────────────────────────────────────────────

def all_pairs_longest_paths(W: np.ndarray, max_length: Optional[int] = None) -> np.ndarray:
    """Compute all-pairs longest path weights using tropical powers.
    
    For a graph with n vertices, the longest simple path has at most
    n-1 edges. This computes the elementwise maximum of tropical
    powers W^{⊗0}, W^{⊗1}, ..., W^{⊗(max_length-1)}.
    
    Time complexity: O(n⁴) when max_length = n-1
    Space complexity: O(n²)
    
    Args:
        W: n×n weight matrix (use -inf for absent edges)
        max_length: maximum path length to consider (default: n-1)
    
    Returns:
        n×n matrix where entry (i,j) is the maximum weight walk
        from i to j of any length up to max_length
    """
    n = W.shape[0]
    if max_length is None:
        max_length = n - 1
    
    # Start with length-1 walks
    best = W.copy()
    current = W.copy()
    
    for _ in range(1, max_length):
        current = tropical_matmul(current, W)
        best = np.maximum(best, current)
    
    return best


# ─────────────────────────────────────────────────────────────────
# Algorithm 4: Boolean Reachability via Tropical Encoding
# ─────────────────────────────────────────────────────────────────

def boolean_reachability(adj: np.ndarray, steps: int) -> np.ndarray:
    """Compute exact-length reachability using tropical encoding.
    
    Encodes a Boolean adjacency matrix into tropical form:
      True → 0.0,  False → -∞
    
    Then uses tropical matrix power to determine which vertex pairs
    are connected by walks of exactly `steps` edges.
    
    Time complexity: O(steps · n³)
    Space complexity: O(n²)
    
    Args:
        adj: n×n Boolean adjacency matrix
        steps: exact number of edges in the walk
    
    Returns:
        n×n Boolean matrix where True means reachable in exactly `steps` steps
    """
    NEG_INF = -np.inf
    W = np.where(adj, 0.0, NEG_INF)
    
    T = tropical_power(W, steps - 1)  # steps-1 because tropPow 0 = W (length 1)
    return np.isfinite(T)


def reachability_up_to(adj: np.ndarray, max_steps: int) -> np.ndarray:
    """Compute reachability within at most max_steps edges.
    
    Returns True if there exists ANY walk of length 1, 2, ..., max_steps.
    
    Time complexity: O(max_steps · n³)
    Space complexity: O(n²)
    
    Args:
        adj: n×n Boolean adjacency matrix
        max_steps: maximum number of edges
    
    Returns:
        n×n Boolean reachability matrix
    """
    NEG_INF = -np.inf
    W = np.where(adj, 0.0, NEG_INF)
    
    reach = np.isfinite(W)
    current = W.copy()
    
    for _ in range(1, max_steps):
        current = tropical_matmul(current, W)
        reach |= np.isfinite(current)
    
    return reach


# ─────────────────────────────────────────────────────────────────
# Algorithm 5: Bellman Iteration (Single-Source Longest Paths)
# ─────────────────────────────────────────────────────────────────

def bellman_tropical(W: np.ndarray, source: int, max_iter: Optional[int] = None) -> np.ndarray:
    """Single-source longest paths via Bellman's tropical recurrence.
    
    Implements the Bellman optimality principle:
      d[j]^{m+1} = max_k (d[k]^m + W[k][j])
    
    This is exactly the row extraction of tropical matrix power.
    
    Time complexity: O(n² · max_iter)
    Space complexity: O(n)
    
    Args:
        W: n×n weight matrix
        source: source vertex index
        max_iter: number of Bellman iterations (default: n-1)
    
    Returns:
        1×n array of longest path weights from source
    """
    n = W.shape[0]
    if max_iter is None:
        max_iter = n - 1
    
    # Initialize: d[j] = W[source][j] (length-1 paths)
    d = W[source].copy()
    
    for _ in range(max_iter):
        d_new = np.full(n, -np.inf)
        for j in range(n):
            d_new[j] = max(d[k] + W[k, j] for k in range(n))
        d = d_new
    
    return d


# ─────────────────────────────────────────────────────────────────
# Example usage
# ─────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("Tropical Matrix Algebra — Algorithm Examples")
    print("=" * 55)
    
    # Example graph
    W = np.array([
        [ 0,  3, -1,  2],
        [ 1,  0,  4, -2],
        [ 5, -3,  0,  1],
        [ 2,  3,  1,  0]
    ], dtype=float)
    
    print("\nWeight matrix W:")
    print(W)
    
    # Tropical multiplication
    print("\n--- Tropical Product W ⊗ W ---")
    W2 = tropical_matmul(W, W)
    print(W2)
    
    # Tropical power
    print("\n--- Tropical Power W^{⊗3} ---")
    W3 = tropical_power(W, 2)
    print(W3)
    
    # Bellman iteration
    print("\n--- Bellman from source 0 (4 iterations) ---")
    d = bellman_tropical(W, source=0, max_iter=4)
    print(f"  Longest path weights: {d}")
    
    # Boolean reachability
    print("\n--- Boolean Reachability (directed cycle) ---")
    G = np.array([
        [False, True,  False, False],
        [False, False, True,  False],
        [False, False, False, True ],
        [True,  False, False, False],
    ])
    
    for steps in [1, 2, 3, 4]:
        R = boolean_reachability(G, steps)
        print(f"  Reachable in exactly {steps} step(s):")
        print(f"    {R.astype(int)}")
    
    # All-pairs longest paths
    print("\n--- All-Pairs Longest Paths (up to length 3) ---")
    best = all_pairs_longest_paths(W, max_length=3)
    print(best)
