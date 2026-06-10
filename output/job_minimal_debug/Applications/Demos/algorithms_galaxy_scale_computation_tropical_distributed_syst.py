#!/usr/bin/env python3
"""
algorithms.py — Tropical Distributed Systems: Core Algorithms

Implements the key algorithms from the research paper:
1. Floyd-Warshall (min-plus matrix closure) for all-pairs shortest paths
2. Tropical broadcast scheduling
3. Idempotent aggregation simulation
4. Speedup analysis under latency constraints

All algorithms include docstrings, type hints, and complexity analysis.
"""

from typing import List, Tuple, Optional, Dict
import math

INF = float('inf')


# ═══════════════════════════════════════════════════════════════════
# Algorithm 1: Floyd-Warshall (Min-Plus Matrix Closure)
# ═══════════════════════════════════════════════════════════════════

def floyd_warshall(w: List[List[float]]) -> List[List[float]]:
    """
    Compute all-pairs shortest paths via Floyd-Warshall.

    This is the min-plus matrix closure: given weight matrix W,
    compute W* = I ⊕ W ⊕ W² ⊕ ... where ⊕ = min, ⊗ = +.

    Args:
        w: n×n weight matrix. w[i][j] = direct edge delay from i to j.
           Use float('inf') for absent edges. w[i][i] should be 0.

    Returns:
        n×n distance matrix d where d[i][j] = shortest path from i to j.

    Complexity:
        Time:  O(n³)
        Space: O(n²)

    Example:
        >>> w = [[0, 1, INF], [INF, 0, 2], [3, INF, 0]]
        >>> d = floyd_warshall(w)
        >>> d[0][2]  # shortest path 0→1→2 = 3
        3
    """
    n = len(w)
    d = [row[:] for row in w]  # deep copy

    for k in range(n):
        for i in range(n):
            for j in range(n):
                if d[i][k] + d[k][j] < d[i][j]:
                    d[i][j] = d[i][k] + d[k][j]

    return d


def floyd_warshall_with_predecessors(
    w: List[List[float]]
) -> Tuple[List[List[float]], List[List[Optional[int]]]]:
    """
    Floyd-Warshall with predecessor tracking for path reconstruction.

    Args:
        w: n×n weight matrix.

    Returns:
        (d, pred) where d[i][j] = shortest distance and
        pred[i][j] = predecessor of j on shortest i→j path.

    Complexity:
        Time:  O(n³)
        Space: O(n²)
    """
    n = len(w)
    d = [row[:] for row in w]
    pred: List[List[Optional[int]]] = [[None] * n for _ in range(n)]

    for i in range(n):
        for j in range(n):
            if i != j and w[i][j] < INF:
                pred[i][j] = i

    for k in range(n):
        for i in range(n):
            for j in range(n):
                if d[i][k] + d[k][j] < d[i][j]:
                    d[i][j] = d[i][k] + d[k][j]
                    pred[i][j] = pred[k][j]

    return d, pred


def reconstruct_path(
    pred: List[List[Optional[int]]], i: int, j: int
) -> Optional[List[int]]:
    """
    Reconstruct shortest path from i to j using predecessor matrix.

    Returns:
        List of nodes from i to j, or None if no path exists.
    """
    if pred[i][j] is None and i != j:
        return None
    path = [j]
    while path[-1] != i:
        p = pred[i][path[-1]]
        if p is None:
            return None
        path.append(p)
    return list(reversed(path))


# ═══════════════════════════════════════════════════════════════════
# Algorithm 2: Tropical Eccentricity and Diameter
# ═══════════════════════════════════════════════════════════════════

def compute_eccentricity(d: List[List[float]], i: int) -> float:
    """
    Compute eccentricity of node i: max shortest-path distance from i.

    Args:
        d: All-pairs shortest-path distance matrix.
        i: Source node index.

    Returns:
        max_j d[i][j]

    Complexity: O(n)
    """
    return max(d[i])


def compute_tropical_diameter(d: List[List[float]]) -> float:
    """
    Compute tropical diameter: max eccentricity over all nodes.

    Args:
        d: All-pairs shortest-path distance matrix.

    Returns:
        max_i max_j d[i][j]

    Complexity: O(n²)
    """
    n = len(d)
    return max(compute_eccentricity(d, i) for i in range(n))


def compute_radius(d: List[List[float]]) -> float:
    """
    Compute tropical radius: min eccentricity over all nodes.
    The center of the network is the node achieving the radius.

    Args:
        d: All-pairs shortest-path distance matrix.

    Returns:
        min_i max_j d[i][j]

    Complexity: O(n²)
    """
    n = len(d)
    return min(compute_eccentricity(d, i) for i in range(n))


def find_center(d: List[List[float]]) -> int:
    """Find the center node (achieving minimum eccentricity)."""
    n = len(d)
    return min(range(n), key=lambda i: compute_eccentricity(d, i))


# ═══════════════════════════════════════════════════════════════════
# Algorithm 3: Optimal Broadcast Scheduling
# ═══════════════════════════════════════════════════════════════════

def optimal_broadcast(
    w: List[List[float]], source: int
) -> Tuple[List[float], Dict[int, int]]:
    """
    Compute optimal broadcast schedule from a source node.

    The optimal strategy is to forward along shortest-path trees.
    The delivery time at each node equals the shortest-path distance
    from the source (Theorem A).

    Args:
        w: n×n weight matrix.
        source: Index of the source node.

    Returns:
        (delivery_times, parent) where delivery_times[j] = optimal
        time for node j to receive the broadcast, and parent[j] =
        the node that forwards to j in the optimal schedule.

    Complexity:
        Time:  O(n² log n) with Dijkstra, O(n³) with Floyd-Warshall
        Space: O(n²)
    """
    d, pred = floyd_warshall_with_predecessors(w)
    delivery = d[source]
    parent = {}
    for j in range(len(w)):
        if j != source:
            p = pred[source][j]
            if p is not None:
                parent[j] = p
    return delivery, parent


def broadcast_completion_time(
    w: List[List[float]], source: int
) -> float:
    """
    Compute optimal broadcast completion time from source.
    This equals the eccentricity of the source.

    Complexity: O(n³) via Floyd-Warshall
    """
    d = floyd_warshall(w)
    return compute_eccentricity(d, source)


# ═══════════════════════════════════════════════════════════════════
# Algorithm 4: Idempotent Aggregation Simulation
# ═══════════════════════════════════════════════════════════════════

def simulate_min_aggregation(
    adj: List[List[float]],
    initial_values: List[float],
    max_rounds: int = 100
) -> Tuple[List[List[float]], int]:
    """
    Simulate min-aggregation on a network until stabilization.

    Each round, every node updates its value to the minimum of its
    current value and all neighbor values. By idempotence + finiteness,
    this converges within at most diameter rounds.

    Args:
        adj: Adjacency matrix (finite weight = connected).
        initial_values: Initial value at each node.
        max_rounds: Maximum rounds to simulate.

    Returns:
        (history, stabilization_round) where history[t] is the state
        vector at round t, and stabilization_round is when convergence
        occurred.

    Complexity per round: O(n²)
    Total: O(n² × diameter)

    Example:
        >>> adj = [[0, 1, INF, 1], [1, 0, 1, INF],
        ...        [INF, 1, 0, 1], [1, INF, 1, 0]]
        >>> vals = [7, 3, 9, 1]
        >>> history, stable = simulate_min_aggregation(adj, vals)
        >>> history[stable]  # [1, 1, 1, 1]
    """
    n = len(initial_values)
    state = initial_values[:]
    history = [state[:]]

    for t in range(1, max_rounds + 1):
        new_state = state[:]
        for i in range(n):
            for j in range(n):
                if adj[i][j] < INF:
                    new_state[i] = min(new_state[i], state[j])
        history.append(new_state[:])
        if new_state == state:
            return history, t
        state = new_state

    return history, max_rounds


def simulate_max_aggregation(
    adj: List[List[float]],
    initial_values: List[float],
    max_rounds: int = 100
) -> Tuple[List[List[float]], int]:
    """
    Simulate max-aggregation (dual of min-aggregation).
    Same convergence guarantees by duality.
    """
    n = len(initial_values)
    neg_vals = [-v for v in initial_values]
    neg_adj = adj  # adjacency structure is the same
    history, stable = simulate_min_aggregation(neg_adj, neg_vals, max_rounds)
    pos_history = [[-v for v in state] for state in history]
    return pos_history, stable


# ═══════════════════════════════════════════════════════════════════
# Algorithm 5: Speedup Analysis
# ═══════════════════════════════════════════════════════════════════

def compute_speedup(W: float, k: int, B: int, D: float) -> float:
    """
    Compute parallel speedup under the latency-aware model.

    Model: T(k) = W/k + B × D
    Speedup: S(k) = W / T(k) = W / (W/k + B × D)

    Args:
        W: Total work.
        k: Number of workers.
        B: Number of synchronization barriers.
        D: Communication delay (tropical diameter).

    Returns:
        Speedup factor S(k).

    Properties (proven in the formal development):
        - S(k) ≤ k always (Theorem B, weak form)
        - S(k) < k when D > 0 and B > 0 (Theorem B, strong form)
    """
    denom = W / k + B * D
    if denom <= 0:
        return float('inf')
    return W / denom


def optimal_worker_count(W: float, B: int, D: float) -> int:
    """
    Find the number of workers maximizing efficiency S(k)/k.

    Beyond this point, adding workers gives diminishing returns.
    The optimal count balances computation and communication.

    Returns:
        Optimal k (approximate).
    """
    if D <= 0 or B <= 0:
        return 1  # No communication overhead

    # At optimum, dS/dk = 0 gives k* = sqrt(W × k / (B × D))
    # Simplified: k* ≈ sqrt(W / (B × D))
    k_opt = max(1, int(math.sqrt(W / (B * D))))
    return k_opt


# ═══════════════════════════════════════════════════════════════════
# Algorithm 6: Min-Plus Matrix Multiplication
# ═══════════════════════════════════════════════════════════════════

def minplus_matmul(
    A: List[List[float]], B: List[List[float]]
) -> List[List[float]]:
    """
    Min-plus (tropical) matrix multiplication.

    (A ⊗ B)[i][j] = min_k (A[i][k] + B[k][j])

    This is the fundamental operation of tropical linear algebra.
    The k-th power W^⊗k gives best k-hop propagation times.

    Complexity: O(n³)
    """
    n = len(A)
    C = [[INF] * n for _ in range(n)]
    for i in range(n):
        for j in range(n):
            for k in range(n):
                val = A[i][k] + B[k][j]
                if val < C[i][j]:
                    C[i][j] = val
    return C


def minplus_closure(W: List[List[float]]) -> List[List[float]]:
    """
    Compute the min-plus (Kleene) closure W* = I ⊕ W ⊕ W² ⊕ ...

    On finite graphs, this equals the all-pairs shortest-path matrix.
    Equivalent to Floyd-Warshall but expressed algebraically.

    Complexity: O(n⁴) via repeated squaring, O(n³) via Floyd-Warshall.
    We use Floyd-Warshall internally.
    """
    return floyd_warshall(W)


# ═══════════════════════════════════════════════════════════════════
# Example usage
# ═══════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("Tropical Distributed Systems — Algorithm Suite")
    print("=" * 60)

    # Small example network
    n = 4
    w = [
        [0, 2, INF, 7],
        [2, 0, 3, INF],
        [INF, 3, 0, 1],
        [7, INF, 1, 0]
    ]

    print("\n1. All-pairs shortest paths (Floyd-Warshall):")
    d = floyd_warshall(w)
    for row in d:
        print(f"   {row}")

    print(f"\n2. Tropical diameter: {compute_tropical_diameter(d)}")
    print(f"   Tropical radius: {compute_radius(d)}")
    print(f"   Center node: {find_center(d)}")

    print("\n3. Optimal broadcast from node 0:")
    times, parent = optimal_broadcast(w, 0)
    print(f"   Delivery times: {times}")
    print(f"   Completion: {max(times)}")

    print("\n4. Min-aggregation simulation:")
    adj = [[0 if i == j else (w[i][j] if w[i][j] < INF else INF) for j in range(n)] for i in range(n)]
    history, stable = simulate_min_aggregation(adj, [10, 5, 8, 2])
    for t, state in enumerate(history):
        print(f"   Round {t}: {state}")
    print(f"   Stabilized at round {stable}")

    print("\n5. Speedup analysis (W=1000, D=5):")
    for k in [1, 2, 4, 8, 16, 32]:
        s = compute_speedup(1000, k, 10, 5)
        print(f"   k={k:2d}: speedup = {s:.2f}x  (efficiency = {s/k:.1%})")
    print(f"   Optimal workers: {optimal_worker_count(1000, 10, 5)}")
