#!/usr/bin/env python3
"""
algorithms.py — Tropical Matrix Power Stabilization: Core Algorithms

Implements the key algorithms from tropical linear algebra:
1. Tropical (min-plus) matrix multiplication — O(n³)
2. Tropical matrix power computation — O(n³ · m)
3. Floyd-Warshall shortest-path closure — O(n³)
4. Bellman-Ford single-source shortest paths — O(n² · m)
5. Boundary distance matrix extraction
6. Stabilization detection

All algorithms operate on weighted adjacency matrices where:
- Entries represent edge weights (float('inf') = no edge)
- Diagonal entries are 0 (self-loops with zero cost)
- The tropical semiring uses (min, +) instead of (+, ×)
"""

from typing import List, Tuple, Optional
import numpy as np

INF = float('inf')


def tropical_multiply(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """
    Tropical (min-plus) matrix multiplication.

    (A ⊗ B)_{ij} = min_k (A_{ik} + B_{kj})

    Time complexity: O(n³)
    Space complexity: O(n²)

    Args:
        A: n×n matrix over ℝ ∪ {∞}
        B: n×n matrix over ℝ ∪ {∞}

    Returns:
        n×n matrix C where C_{ij} = min_k (A_{ik} + B_{kj})
    """
    n = A.shape[0]
    assert A.shape == B.shape == (n, n), "Matrices must be square and same size"

    C = np.full((n, n), INF)
    for i in range(n):
        for j in range(n):
            for k in range(n):
                val = A[i, k] + B[k, j]
                if val < C[i, j]:
                    C[i, j] = val
    return C


def tropical_power(W: np.ndarray, m: int) -> np.ndarray:
    """
    Compute the m-th tropical power W^⊗m (1-indexed: W^⊗1 = W).

    W^⊗m_{ij} = minimum weight of a walk from i to j using exactly m edges.

    Time complexity: O(n³ · m)
    Space complexity: O(n²)

    Args:
        W: n×n weight matrix with 0 diagonal
        m: power index (m ≥ 1)

    Returns:
        W^⊗m
    """
    assert m >= 1, "Power must be at least 1"
    result = W.copy()
    for _ in range(m - 1):
        result = tropical_multiply(result, W)
    return result


def floyd_warshall(W: np.ndarray) -> np.ndarray:
    """
    Floyd-Warshall all-pairs shortest paths.

    Computes D where D_{ij} = shortest path distance from i to j.
    Equivalent to the tropical Kleene star (closure).

    Time complexity: O(n³)
    Space complexity: O(n²)

    Args:
        W: n×n weight matrix (INF = no edge, diagonal = 0)

    Returns:
        n×n shortest-path distance matrix D

    Algorithm:
        D^(0)_{ij} = W_{ij} (with D_{ii} = 0)
        D^(k)_{ij} = min(D^(k-1)_{ij}, D^(k-1)_{ik} + D^(k-1)_{kj})
        D = D^(n)
    """
    n = W.shape[0]
    D = W.copy()
    np.fill_diagonal(D, 0)

    for k in range(n):
        for i in range(n):
            for j in range(n):
                via_k = D[i, k] + D[k, j]
                if via_k < D[i, j]:
                    D[i, j] = via_k
    return D


def bellman_ford(W: np.ndarray, source: int) -> Tuple[np.ndarray, bool]:
    """
    Bellman-Ford single-source shortest paths.

    This is the row-wise version of tropical power stabilization:
    the source row of W^⊗k converges to shortest-path distances.

    Time complexity: O(n²)  (n-1 relaxation rounds × n edges per round)
    Space complexity: O(n)

    Args:
        W: n×n weight matrix
        source: source vertex index

    Returns:
        (distances, has_negative_cycle)
        - distances: array of shortest-path distances from source
        - has_negative_cycle: True if a negative cycle is reachable
    """
    n = W.shape[0]
    dist = np.full(n, INF)
    dist[source] = 0

    # Relax n-1 times (corresponds to tropical powers 1..n-1)
    for _ in range(n - 1):
        for u in range(n):
            if dist[u] < INF:
                for v in range(n):
                    if dist[u] + W[u, v] < dist[v]:
                        dist[v] = dist[u] + W[u, v]

    # Check for negative cycles (one more relaxation round)
    has_neg_cycle = False
    for u in range(n):
        if dist[u] < INF:
            for v in range(n):
                if dist[u] + W[u, v] < dist[v] - 1e-10:
                    has_neg_cycle = True

    return dist, has_neg_cycle


def detect_stabilization(W: np.ndarray, max_power: int = None) -> int:
    """
    Detect the stabilization point of tropical powers.

    Returns the smallest m such that W^⊗(m+1) = W^⊗m (off-diagonal).
    By our theorem, this is at most n-2 (0-indexed) for matrices
    with zero diagonal and no negative cycles.

    Time complexity: O(n³ · n) worst case
    Space complexity: O(n²)

    Args:
        W: n×n weight matrix with 0 diagonal
        max_power: maximum power to check (default: 2n)

    Returns:
        Stabilization index m (0-indexed, so W^⊗(m+1) is the stable power)
    """
    n = W.shape[0]
    if max_power is None:
        max_power = 2 * n

    prev = W.copy()
    for m in range(1, max_power):
        curr = tropical_multiply(prev, W)

        # Check off-diagonal entries
        stabilized = True
        for i in range(n):
            for j in range(n):
                if i != j and abs(curr[i, j] - prev[i, j]) > 1e-10:
                    stabilized = False
                    break
            if not stabilized:
                break

        if stabilized:
            return m - 1  # Previous power was already stable

        prev = curr

    return max_power - 1


def boundary_distance_matrix(W: np.ndarray,
                              boundary: List[int]) -> np.ndarray:
    """
    Extract the boundary distance matrix from a weighted graph.

    Given a weight matrix W and boundary vertices B, computes
    the |B|×|B| matrix of shortest-path distances between boundary vertices.

    This is the tropical analogue of the Dirichlet-to-Neumann operator.

    Time complexity: O(n³) for Floyd-Warshall + O(|B|²)
    Space complexity: O(n²)

    Args:
        W: n×n weight matrix
        boundary: list of boundary vertex indices

    Returns:
        |B|×|B| boundary distance matrix
    """
    D = floyd_warshall(W)
    b = len(boundary)
    D_B = np.zeros((b, b))
    for i in range(b):
        for j in range(b):
            D_B[i, j] = D[boundary[i], boundary[j]]
    return D_B


def verify_triangle_inequality(D: np.ndarray) -> List[Tuple[int, int, int]]:
    """
    Verify the triangle inequality D_{ij} ≤ D_{ik} + D_{kj} for all i,j,k.

    Returns list of violating triples (i, j, k).
    """
    n = D.shape[0]
    violations = []
    for i in range(n):
        for j in range(n):
            for k in range(n):
                if D[i, j] > D[i, k] + D[k, j] + 1e-10:
                    violations.append((i, j, k))
    return violations


def check_no_negative_cycles(W: np.ndarray, max_power: int = None) -> bool:
    """
    Check the NoNegDiag condition: all diagonal entries of tropical powers ≥ 0.

    Args:
        W: n×n weight matrix with 0 diagonal
        max_power: number of powers to check (default: 2n)

    Returns:
        True if NoNegDiag holds (no negative cycles)
    """
    n = W.shape[0]
    if max_power is None:
        max_power = 2 * n

    curr = W.copy()
    for m in range(max_power):
        for i in range(n):
            if curr[i, i] < -1e-10:
                return False
        curr = tropical_multiply(curr, W)
    return True


# ============================================================
# Example usage
# ============================================================
if __name__ == "__main__":
    print("Tropical Matrix Power Stabilization — Algorithm Suite")
    print("=" * 55)

    # Example: 4-vertex graph
    W = np.array([
        [0,   1, INF, INF],
        [INF, 0,   2,   7],
        [INF, INF, 0,   3],
        [4,   INF, INF, 0]
    ], dtype=float)

    print("\nWeight matrix W:")
    print(W)

    # Tropical powers
    print("\nTropical powers (off-diagonal entries):")
    for m in range(1, 7):
        Wm = tropical_power(W, m)
        print(f"  W^⊗{m}: {[[Wm[i,j] for j in range(4)] for i in range(4)]}")

    # Stabilization detection
    stab = detect_stabilization(W)
    print(f"\nStabilization detected at index: {stab}")
    print(f"Expected (n-2): {W.shape[0] - 2}")

    # Floyd-Warshall
    D = floyd_warshall(W)
    print(f"\nFloyd-Warshall shortest paths:")
    print(D)

    # Bellman-Ford from vertex 0
    dist, neg = bellman_ford(W, 0)
    print(f"\nBellman-Ford from vertex 0:")
    print(f"  Distances: {dist}")
    print(f"  Negative cycle: {neg}")

    # Triangle inequality
    violations = verify_triangle_inequality(D)
    print(f"\nTriangle inequality: {len(violations)} violations")

    # NoNegDiag
    print(f"\nNo negative cycles: {check_no_negative_cycles(W)}")

    # Boundary distance
    boundary = [0, 2]
    D_B = boundary_distance_matrix(W, boundary)
    print(f"\nBoundary distance matrix (vertices {boundary}):")
    print(D_B)
