#!/usr/bin/env python3
"""
Algorithms for Tropical Magnetic Perturbation Theory.

Implements:
1. Charged Bellman-Ford shortest path computation
2. Gauge decomposition (exact + curl)
3. Cycle flux computation
4. Lorentz bound certificate verification
"""

import numpy as np
from typing import Dict, List, Tuple, Optional, Set
from collections import defaultdict


def bellman_ford(
    n: int,
    edges: List[Tuple[int, int, float]],
    source: int,
) -> Tuple[List[float], List[int]]:
    """Standard Bellman-Ford shortest path algorithm.

    Args:
        n: Number of vertices (0-indexed)
        edges: List of (u, v, weight) triples
        source: Source vertex

    Returns:
        (dist, pred) where dist[v] is shortest distance from source to v,
        pred[v] is predecessor of v on shortest path (-1 if none)
    """
    dist = [float('inf')] * n
    pred = [-1] * n
    dist[source] = 0.0

    for _ in range(n - 1):
        updated = False
        for u, v, w in edges:
            if dist[u] + w < dist[v]:
                dist[v] = dist[u] + w
                pred[v] = u
                updated = True
        if not updated:
            break

    return dist, pred


def charged_bellman_ford(
    n: int,
    edges: List[Tuple[int, int, float]],
    A: Dict[Tuple[int, int], float],
    q: float,
    source: int,
) -> Tuple[List[float], List[int]]:
    """Bellman-Ford with charged weights W_q = W + q*A.

    Args:
        n: Number of vertices
        edges: List of (u, v, weight) triples (original weights)
        A: Antisymmetric vector potential {(u,v): value}
        q: Charge parameter
        source: Source vertex

    Returns:
        (dist, pred) under charged weights
    """
    charged_edges = [
        (u, v, w + q * A.get((u, v), 0.0))
        for u, v, w in edges
    ]
    return bellman_ford(n, charged_edges, source)


def reconstruct_path(pred: List[int], target: int) -> List[int]:
    """Reconstruct shortest path from predecessor array.

    Args:
        pred: Predecessor array from Bellman-Ford
        target: Target vertex

    Returns:
        List of vertices from source to target
    """
    path = []
    v = target
    while v != -1:
        path.append(v)
        v = pred[v]
    return list(reversed(path))


def gauge_decomposition(
    n: int,
    edges: List[Tuple[int, int]],
    A: Dict[Tuple[int, int], float],
    root: int = 0,
) -> Tuple[Dict[int, float], Dict[Tuple[int, int], float]]:
    """Decompose A into exact part (dφ) and curl part.

    Uses BFS spanning tree to define the scalar potential φ,
    then A_curl = A - dφ.

    Args:
        n: Number of vertices
        edges: List of (u, v) directed edge pairs
        A: Vector potential values
        root: Root vertex for the spanning tree

    Returns:
        (phi, A_curl) where phi is the scalar potential and
        A_curl is the residual curl component
    """
    # Build adjacency (undirected)
    adj: Dict[int, List[int]] = defaultdict(list)
    for u, v in edges:
        adj[u].append(v)
        adj[v].append(u)

    # BFS spanning tree
    phi: Dict[int, float] = {root: 0.0}
    queue = [root]
    visited: Set[int] = {root}

    while queue:
        next_queue = []
        for u in queue:
            for v in adj[u]:
                if v not in visited:
                    visited.add(v)
                    phi[v] = phi[u] + A.get((u, v), 0.0)
                    next_queue.append(v)
        queue = next_queue

    # Compute curl component
    A_curl: Dict[Tuple[int, int], float] = {}
    for u, v in edges:
        if u in phi and v in phi:
            A_curl[(u, v)] = A.get((u, v), 0.0) - (phi[v] - phi[u])

    return phi, A_curl


def cycle_flux(
    A: Dict[Tuple[int, int], float],
    cycle: List[int],
) -> float:
    """Compute the magnetic flux through a cycle.

    Args:
        A: Vector potential
        cycle: List of vertices forming a closed loop (first = last)

    Returns:
        Total flux Σ A(v_i, v_{i+1}) around the cycle
    """
    return sum(
        A.get((cycle[i], cycle[i+1]), 0.0)
        for i in range(len(cycle) - 1)
    )


def lorentz_bound_certificate(
    W: Dict[Tuple[int, int], float],
    A: Dict[Tuple[int, int], float],
    q: float,
    max_A: float,
    L: int,
    source: int,
    target: int,
    d_W: float,
    d_Wq: float,
) -> Dict[str, object]:
    """Verify the Lorentz bound for a specific source-target pair.

    Args:
        W: Original edge weights
        A: Vector potential
        q: Charge parameter
        max_A: Uniform bound on |A|
        L: Maximum path length
        source, target: Endpoints
        d_W: Shortest distance under W
        d_Wq: Shortest distance under W_q

    Returns:
        Certificate dictionary with bound verification
    """
    bound = abs(q) * max_A * L
    deviation = abs(d_Wq - d_W)
    satisfied = deviation <= bound + 1e-12

    return {
        "source": source,
        "target": target,
        "d_W": d_W,
        "d_Wq": d_Wq,
        "deviation": deviation,
        "bound": bound,
        "ratio": deviation / bound if bound > 0 else 0.0,
        "satisfied": satisfied,
        "q": q,
        "max_A": max_A,
        "L": L,
    }


def yang_mills_functional(
    A: Dict[Tuple[int, int], float],
    cycles: List[List[int]],
) -> float:
    """Compute the tropical Yang-Mills functional.

    YM(A) = Σ_C (Φ_A(C))^2

    Args:
        A: Vector potential
        cycles: List of fundamental cycles

    Returns:
        Total squared cycle flux
    """
    return sum(cycle_flux(A, c) ** 2 for c in cycles)


# === Example usage ===

if __name__ == "__main__":
    print("=== Charged Bellman-Ford Demo ===\n")

    # Small graph: 5 vertices, some edges
    n = 5
    edges_with_weights = [
        (0, 1, 2.0), (0, 2, 5.0), (1, 2, 1.0),
        (1, 3, 4.0), (2, 3, 2.0), (2, 4, 6.0),
        (3, 4, 1.0),
    ]

    # Antisymmetric potential
    A = {
        (0, 1): 0.5, (1, 0): -0.5,
        (0, 2): -0.3, (2, 0): 0.3,
        (1, 2): 0.7, (2, 1): -0.7,
        (1, 3): -0.2, (3, 1): 0.2,
        (2, 3): 0.4, (3, 2): -0.4,
        (2, 4): -0.1, (4, 2): 0.1,
        (3, 4): 0.6, (4, 3): -0.6,
    }

    q = 1.0
    source = 0

    dist_W, pred_W = bellman_ford(n, edges_with_weights, source)
    dist_Wq, pred_Wq = charged_bellman_ford(n, edges_with_weights, A, q, source)

    print(f"Charge q = {q}")
    print(f"\n{'Target':>8} {'d_W':>10} {'d_Wq':>10} {'|Δ|':>10} {'Path_W':>20} {'Path_Wq':>20}")
    print("-" * 82)

    for t in range(n):
        path_W = reconstruct_path(pred_W, t)
        path_Wq = reconstruct_path(pred_Wq, t)
        delta = abs(dist_Wq[t] - dist_W[t])
        print(f"{t:>8} {dist_W[t]:>10.3f} {dist_Wq[t]:>10.3f} {delta:>10.3f} {str(path_W):>20} {str(path_Wq):>20}")

    # Gauge decomposition
    print("\n\n=== Gauge Decomposition Demo ===\n")
    directed_edges = [(u, v) for u, v, _ in edges_with_weights]
    phi, A_curl = gauge_decomposition(n, directed_edges, A)

    print(f"Scalar potential φ: {dict(sorted(phi.items()))}")
    print(f"\nCurl component A_curl:")
    for (u, v), val in sorted(A_curl.items()):
        if abs(val) > 1e-10:
            print(f"  ({u},{v}): {val:.4f}")

    # Verify: cycle flux of exact part is zero
    test_cycle = [0, 1, 2, 0]  # Need edge (2,0) in A
    A_exact = {(u, v): phi.get(v, 0) - phi.get(u, 0) for u, v in A.keys()}
    print(f"\nCycle {test_cycle}:")
    print(f"  Flux of A:       {cycle_flux(A, test_cycle):.4f}")
    print(f"  Flux of A_exact: {cycle_flux(A_exact, test_cycle):.6f} (should be ~0)")
    print(f"  Flux of A_curl:  {cycle_flux(A_curl, test_cycle):.4f}")

    # Yang-Mills functional
    print("\n\n=== Yang-Mills Functional Demo ===\n")
    cycles = [[0, 1, 2, 0], [1, 2, 3, 1], [2, 3, 4, 2]]
    ym_A = yang_mills_functional(A, cycles)
    ym_exact = yang_mills_functional(A_exact, cycles)
    ym_curl = yang_mills_functional(A_curl, cycles)
    print(f"YM(A)       = {ym_A:.6f}")
    print(f"YM(A_exact) = {ym_exact:.6f} (should be ~0)")
    print(f"YM(A_curl)  = {ym_curl:.6f}")
