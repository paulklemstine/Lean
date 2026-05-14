#!/usr/bin/env python3
"""
Tropical Distributed Systems: Core Algorithms

Implements the key algorithms from the formal theory:
1. Bellman-Ford (single-source shortest paths in min-plus semiring)
2. Floyd-Warshall (all-pairs shortest paths / tropical matrix closure)
3. Tropical broadcast simulation
4. Idempotent aggregation convergence
5. Speedup analysis under diameter constraints

All algorithms include type hints, docstrings, and complexity analysis.
"""

from __future__ import annotations
import numpy as np
from dataclasses import dataclass, field
from typing import Optional
import heapq

INF = float('inf')


# ============================================================
# Algorithm 1: Bellman-Ford (Min-Plus Relaxation)
# ============================================================

def bellman_ford(
    w: np.ndarray,
    source: int,
    max_steps: Optional[int] = None
) -> tuple[np.ndarray, np.ndarray]:
    """
    Single-source shortest paths via Bellman-Ford relaxation.

    This is the computational realization of the Bellman-Ford iteration
    defined in the Lean formalization (bellmanFord/bfIter).

    Args:
        w: n×n weight matrix with w[i][i] = 0 and w[i][j] ≥ 0.
           INF = no edge.
        source: Source node index.
        max_steps: Maximum relaxation steps (default: n-1).

    Returns:
        (dist, parent): shortest distances and predecessor array.

    Complexity:
        Time:  O(n³) worst case, O(n²) per step × (n-1) steps
        Space: O(n)

    Convergence:
        For non-negative weights, converges in at most n-1 steps.
        Each step k computes shortest paths using at most k+1 edges.
    """
    n = w.shape[0]
    if max_steps is None:
        max_steps = n - 1

    dist = np.full(n, INF)
    dist[source] = 0.0
    parent = np.full(n, -1, dtype=int)

    for step in range(max_steps):
        updated = False
        for j in range(n):
            for i in range(n):
                if dist[i] + w[i][j] < dist[j]:
                    dist[j] = dist[i] + w[i][j]
                    parent[j] = i
                    updated = True
        if not updated:
            break  # Early termination: already converged

    return dist, parent


# ============================================================
# Algorithm 2: Floyd-Warshall (Tropical Matrix Closure)
# ============================================================

def floyd_warshall(w: np.ndarray) -> tuple[np.ndarray, np.ndarray]:
    """
    All-pairs shortest paths via Floyd-Warshall.

    Computes the Kleene star (tropical closure) of the weight matrix:
    W* = I ⊕ W ⊕ W² ⊕ W³ ⊕ ...
    where ⊕ = min, ⊗ = + (min-plus semiring operations).

    Args:
        w: n×n weight matrix.

    Returns:
        (dist, next_hop): distance matrix and routing table.

    Complexity:
        Time:  O(n³)
        Space: O(n²)

    This is the min-plus analog of matrix inversion / Gaussian elimination.
    """
    n = w.shape[0]
    dist = w.copy()
    next_hop = np.full((n, n), -1, dtype=int)

    for i in range(n):
        for j in range(n):
            if w[i][j] < INF and i != j:
                next_hop[i][j] = j

    for k in range(n):
        for i in range(n):
            for j in range(n):
                if dist[i][k] + dist[k][j] < dist[i][j]:
                    dist[i][j] = dist[i][k] + dist[k][j]
                    next_hop[i][j] = next_hop[i][k]

    return dist, next_hop


# ============================================================
# Algorithm 3: Tropical Broadcast Simulation
# ============================================================

@dataclass
class BroadcastResult:
    """Result of a broadcast simulation."""
    delivery_times: np.ndarray
    delivery_order: list[int]
    parent: np.ndarray
    completion_time: float
    eccentricity: float
    is_optimal: bool


def simulate_broadcast(
    w: np.ndarray,
    source: int
) -> BroadcastResult:
    """
    Simulate optimal (flooding) broadcast from a source node.

    Uses Dijkstra's algorithm to compute the shortest-path tree,
    which gives the optimal broadcast schedule (= eccentricity).

    Args:
        w: n×n weight matrix.
        source: Source node.

    Returns:
        BroadcastResult with delivery times, order, and optimality info.

    Complexity:
        Time:  O(n² log n) with binary heap, O(n²) with simple scan
        Space: O(n)

    The delivery time at each node equals shortestDist(source, node),
    as proven in Theorem A of the formalization.
    """
    n = w.shape[0]
    dist = np.full(n, INF)
    dist[source] = 0.0
    parent = np.full(n, -1, dtype=int)
    visited = np.zeros(n, dtype=bool)
    delivery_order = []

    # Priority queue: (distance, node)
    pq = [(0.0, source)]

    while pq:
        d, u = heapq.heappop(pq)
        if visited[u]:
            continue
        visited[u] = True
        delivery_order.append(u)
        dist[u] = d

        for v in range(n):
            if not visited[v] and d + w[u][v] < dist[v]:
                dist[v] = d + w[u][v]
                parent[v] = u
                heapq.heappush(pq, (dist[v], v))

    completion = max(dist[dist < INF]) if any(dist < INF) else INF

    # Compute eccentricity for comparison
    all_pairs, _ = floyd_warshall(w)
    ecc = max(all_pairs[source])

    return BroadcastResult(
        delivery_times=dist,
        delivery_order=delivery_order,
        parent=parent,
        completion_time=completion,
        eccentricity=ecc,
        is_optimal=abs(completion - ecc) < 1e-10
    )


# ============================================================
# Algorithm 4: Idempotent Aggregation Convergence
# ============================================================

@dataclass
class AggregationResult:
    """Result of idempotent aggregation convergence simulation."""
    initial_states: list[list[float]]
    final_states: list[list[float]]
    converged_state: list[float]
    steps_to_converge: int
    exchange_log: list[tuple[int, int]]


def simulate_idempotent_aggregation(
    initial_states: list[list[float]],
    exchange_pairs: list[tuple[int, int]],
    op=min
) -> AggregationResult:
    """
    Simulate idempotent aggregation over a network.

    Each step: two nodes exchange their state vectors and take
    the pointwise min (or max, or any idempotent commutative operation).

    Args:
        initial_states: List of state vectors, one per node.
        exchange_pairs: Sequence of (node_a, node_b) exchanges.
        op: Aggregation operation (default: min). Must be idempotent + commutative.

    Returns:
        AggregationResult with convergence information.

    Complexity:
        Time:  O(K × n × d) where K = exchanges, n = nodes, d = state dimension
        Space: O(n × d)

    Convergence guarantee (Theorem C):
        For idempotent commutative operations, the final state depends only
        on the SET of initial states that have been "seen" by each node,
        not on the order or multiplicity of exchanges.
    """
    n = len(initial_states)
    d = len(initial_states[0])
    states = [list(s) for s in initial_states]

    # Compute the true converged state (pointwise op over all)
    converged = [
        min(states[j][i] for j in range(n))  # Using min as default
        for i in range(d)
    ]

    exchange_log = []
    steps = 0

    for a, b in exchange_pairs:
        new_state = [op(states[a][i], states[b][i]) for i in range(d)]
        states[a] = list(new_state)
        states[b] = list(new_state)
        exchange_log.append((a, b))
        steps += 1

        # Check convergence
        if all(states[j] == converged for j in range(n)):
            break

    return AggregationResult(
        initial_states=[list(s) for s in initial_states],
        final_states=states,
        converged_state=converged,
        steps_to_converge=steps,
        exchange_log=exchange_log
    )


# ============================================================
# Algorithm 5: Speedup Analysis
# ============================================================

@dataclass
class SpeedupAnalysis:
    """Analysis of parallel speedup under diameter constraints."""
    W: float  # Total work
    D: float  # Network diameter
    B: float  # Barrier count
    workers: list[int]
    runtimes: list[float]
    speedups: list[float]
    efficiencies: list[float]
    gaps: list[float]


def analyze_speedup(
    W: float,
    D: float,
    B: float,
    workers: list[int]
) -> SpeedupAnalysis:
    """
    Analyze parallel speedup under diameter-induced latency.

    Model: T(k) = W/k + B*D
    Speedup: S(k) = W / T(k) = W / (W/k + B*D)
    Gap: k - S(k) = k²BD / (W + kBD)   [proven exactly in Lean]

    Args:
        W: Total computation work.
        D: Network tropical diameter.
        B: Number of synchronization barriers.
        workers: List of worker counts to analyze.

    Returns:
        SpeedupAnalysis with detailed metrics.

    Key insight (Theorem B):
        S(k) < k whenever D > 0 and B > 0.
        The gap grows quadratically in k, making massive parallelism
        futile when diameter is large relative to work per barrier.
    """
    runtimes = []
    speedups = []
    efficiencies = []
    gaps = []

    for k in workers:
        T = W / k + B * D
        S = W / T if T > 0 else INF
        eff = S / k if k > 0 else 0
        gap = k - S

        runtimes.append(T)
        speedups.append(S)
        efficiencies.append(eff)
        gaps.append(gap)

    return SpeedupAnalysis(
        W=W, D=D, B=B,
        workers=workers,
        runtimes=runtimes,
        speedups=speedups,
        efficiencies=efficiencies,
        gaps=gaps
    )


# ============================================================
# Algorithm 6: Tropical Network Metrics
# ============================================================

def compute_network_metrics(w: np.ndarray) -> dict:
    """
    Compute all tropical network metrics from a weight matrix.

    Returns:
        Dictionary with:
        - dist: all-pairs shortest distance matrix
        - eccentricities: eccentricity of each node
        - diameter: tropical diameter
        - radius: tropical radius (min eccentricity)
        - center: set of nodes achieving minimum eccentricity
        - periphery: set of nodes achieving maximum eccentricity
    """
    n = w.shape[0]
    dist, next_hop = floyd_warshall(w)

    eccentricities = [max(dist[i]) for i in range(n)]
    diameter = max(eccentricities)
    radius = min(e for e in eccentricities if e < INF) if any(e < INF for e in eccentricities) else INF

    center = [i for i in range(n) if eccentricities[i] == radius]
    periphery = [i for i in range(n) if eccentricities[i] == diameter]

    return {
        'dist': dist,
        'next_hop': next_hop,
        'eccentricities': eccentricities,
        'diameter': diameter,
        'radius': radius,
        'center': center,
        'periphery': periphery,
    }


if __name__ == '__main__':
    # Example usage
    w = np.array([
        [0,   3,   8, INF, INF],
        [INF, 0,   2,   5, INF],
        [INF, INF, 0,   1,   6],
        [INF, INF, INF, 0,   4],
        [INF, INF, INF, INF, 0],
    ])

    print("=== Tropical Network Metrics ===")
    metrics = compute_network_metrics(w)
    print(f"Diameter: {metrics['diameter']}")
    print(f"Radius:   {metrics['radius']}")
    print(f"Center:   {metrics['center']}")
    print(f"Periphery: {metrics['periphery']}")

    print("\n=== Broadcast Simulation ===")
    result = simulate_broadcast(w, 0)
    print(f"Delivery times: {result.delivery_times}")
    print(f"Completion time: {result.completion_time}")
    print(f"Eccentricity:    {result.eccentricity}")
    print(f"Is optimal:      {result.is_optimal}")

    print("\n=== Speedup Analysis ===")
    analysis = analyze_speedup(W=1000, D=metrics['diameter'], B=10, workers=[1,2,4,8,16,32])
    for k, S, eff in zip(analysis.workers, analysis.speedups, analysis.efficiencies):
        print(f"  k={k:>3}: speedup={S:.2f}, efficiency={eff:.1%}")
