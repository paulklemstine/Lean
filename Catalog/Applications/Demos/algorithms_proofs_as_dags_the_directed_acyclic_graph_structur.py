#!/usr/bin/env python3
"""
Algorithms for Proof DAG Analysis

Type-hinted implementations of the core algorithms for analyzing
the stratified dependency structure of mathematical proof networks.
"""

from typing import List, Tuple, Set, Dict, Optional
from collections import defaultdict
import math


def topological_sort(n: int, edges: List[Tuple[int, int]]) -> Optional[List[int]]:
    """
    Kahn's algorithm for topological sorting.
    Returns None if the graph has a cycle (not a DAG).

    Time: O(n + m) where m = |edges|
    """
    adj: Dict[int, List[int]] = defaultdict(list)
    in_deg: Dict[int, int] = defaultdict(int)
    for i in range(n):
        in_deg[i] = 0
    for u, v in edges:
        adj[u].append(v)
        in_deg[v] += 1

    queue = [v for v in range(n) if in_deg[v] == 0]
    order: List[int] = []
    while queue:
        u = queue.pop(0)
        order.append(u)
        for v in adj[u]:
            in_deg[v] -= 1
            if in_deg[v] == 0:
                queue.append(v)

    return order if len(order) == n else None


def compute_ranks(n: int, edges: List[Tuple[int, int]]) -> Optional[List[int]]:
    """
    Compute the rank (longest path from any source) for each node.
    This gives the canonical stratification of the DAG.

    Time: O(n + m)
    """
    topo = topological_sort(n, edges)
    if topo is None:
        return None

    adj: Dict[int, List[int]] = defaultdict(list)
    for u, v in edges:
        adj[u].append(v)

    ranks = [0] * n
    for u in topo:
        for v in adj[u]:
            ranks[v] = max(ranks[v], ranks[u] + 1)
    return ranks


def compute_dependency_cones(n: int, edges: List[Tuple[int, int]]) -> Dict[int, Set[int]]:
    """
    Compute the dependency cone (transitive closure of successors) for each node.

    Time: O(n * (n + m)) worst case
    """
    adj: Dict[int, List[int]] = defaultdict(list)
    for u, v in edges:
        adj[u].append(v)

    cones: Dict[int, Set[int]] = {}
    # Process in reverse topological order for efficiency
    topo = topological_sort(n, edges)
    if topo is None:
        return {}

    for u in reversed(topo):
        cone: Set[int] = set()
        for v in adj[u]:
            cone.add(v)
            cone |= cones.get(v, set())
        cones[u] = cone

    return cones


def hub_scores(n: int, edges: List[Tuple[int, int]]) -> List[Tuple[int, int]]:
    """
    Compute hub scores (out-degrees) for all nodes, sorted descending.
    """
    out_deg: Dict[int, int] = defaultdict(int)
    for u, v in edges:
        out_deg[u] += 1
    scores = [(i, out_deg.get(i, 0)) for i in range(n)]
    scores.sort(key=lambda x: -x[1])
    return scores


def fragility_index(n: int, edges: List[Tuple[int, int]]) -> float:
    """
    Compute the fragility index: max|cone(v)| / n.
    Measures how dependent the network is on its most influential hub.
    """
    if n == 0:
        return 0.0
    cones = compute_dependency_cones(n, edges)
    max_cone = max((len(c) for c in cones.values()), default=0)
    return max_cone / n


def bottleneck_analysis(n: int, ranks: List[int]) -> Dict[str, any]:
    """
    Compute the bottleneck structure of a stratified DAG.
    Returns the width of each level and identifies bottleneck levels.
    """
    level_counts: Dict[int, int] = defaultdict(int)
    for r in ranks:
        level_counts[r] += 1

    num_levels = len(level_counts)
    min_width = min(level_counts.values()) if level_counts else 0
    max_width = max(level_counts.values()) if level_counts else 0
    avg_width = n / num_levels if num_levels > 0 else 0

    bottleneck_levels = [k for k, v in level_counts.items() if v == min_width]

    return {
        "num_levels": num_levels,
        "level_widths": dict(level_counts),
        "min_width": min_width,
        "max_width": max_width,
        "avg_width": avg_width,
        "bottleneck_levels": bottleneck_levels,
        "bottleneck_theorem_bound": n // num_levels if num_levels > 0 else 0,
    }


def hub_concentration_ratio(n: int, edges: List[Tuple[int, int]]) -> float:
    """
    Compute the hub concentration ratio: max_out_degree / avg_out_degree.
    High values indicate scale-free-like structure.
    """
    if n == 0 or len(edges) == 0:
        return 0.0
    out_deg: Dict[int, int] = defaultdict(int)
    for u, v in edges:
        out_deg[u] += 1
    max_out = max(out_deg.values())
    avg_out = len(edges) / n
    return max_out / avg_out


def edge_span_distribution(
    n: int, edges: List[Tuple[int, int]], ranks: List[int]
) -> Dict[int, int]:
    """
    Compute the distribution of edge spans (rank differences).
    """
    span_dist: Dict[int, int] = defaultdict(int)
    for u, v in edges:
        span = ranks[v] - ranks[u]
        span_dist[span] += 1
    return dict(sorted(span_dist.items()))


def simulate_hub_removal(
    n: int, edges: List[Tuple[int, int]], hub: int
) -> Dict[str, any]:
    """
    Simulate removing a hub node and analyze the impact on the DAG.
    Returns statistics about the disconnected components.
    """
    remaining_edges = [(u, v) for u, v in edges if u != hub and v != hub]
    remaining_nodes = [i for i in range(n) if i != hub]

    # Compute weakly connected components (treating edges as undirected)
    adj: Dict[int, Set[int]] = defaultdict(set)
    for u, v in remaining_edges:
        adj[u].add(v)
        adj[v].add(u)

    visited: Set[int] = set()
    components: List[Set[int]] = []
    for node in remaining_nodes:
        if node not in visited:
            component: Set[int] = set()
            stack = [node]
            while stack:
                curr = stack.pop()
                if curr not in visited:
                    visited.add(curr)
                    component.add(curr)
                    for neighbor in adj[curr]:
                        if neighbor not in visited:
                            stack.append(neighbor)
            components.append(component)

    return {
        "hub_removed": hub,
        "hub_out_degree": sum(1 for u, v in edges if u == hub),
        "hub_in_degree": sum(1 for u, v in edges if v == hub),
        "num_components": len(components),
        "component_sizes": sorted([len(c) for c in components], reverse=True),
        "edges_removed": len(edges) - len(remaining_edges),
        "nodes_in_largest_component": max(len(c) for c in components) if components else 0,
    }


def power_law_fit(degrees: List[int]) -> Tuple[float, float]:
    """
    Fit a power law P(k) ~ k^{-gamma} using maximum likelihood estimation
    (Clauset-Shalizi-Newman method for discrete power laws).

    Returns (gamma, x_min).
    """
    # Filter out zeros
    data = sorted([d for d in degrees if d > 0])
    if len(data) < 10:
        return (0.0, 0)

    # Simple MLE for discrete power law
    x_min = 1
    n_data = len([d for d in data if d >= x_min])
    if n_data == 0:
        return (0.0, x_min)

    # MLE estimator: gamma = 1 + n * [sum(ln(x_i / (x_min - 0.5)))]^{-1}
    log_sum = sum(math.log(d / (x_min - 0.5)) for d in data if d >= x_min)
    if log_sum == 0:
        return (0.0, x_min)

    gamma = 1 + n_data / log_sum
    return (gamma, x_min)


if __name__ == "__main__":
    # Demo: analyze the real analysis proof DAG
    n = 10
    edges = [
        (0, 1), (0, 2), (0, 3), (2, 3), (1, 4), (3, 4),
        (0, 5), (3, 6), (5, 6), (5, 7), (6, 7), (7, 8), (8, 9),
    ]
    ranks_list = compute_ranks(n, edges)
    print(f"Ranks: {ranks_list}")
    print(f"Hub scores: {hub_scores(n, edges)[:5]}")
    print(f"Fragility index: {fragility_index(n, edges):.3f}")
    print(f"Bottleneck: {bottleneck_analysis(n, ranks_list)}")
    print(f"Edge spans: {edge_span_distribution(n, edges, ranks_list)}")
    print(f"Hub concentration: {hub_concentration_ratio(n, edges):.2f}")

    # Hub removal analysis
    for hub in [0, 5]:
        result = simulate_hub_removal(n, edges, hub)
        print(f"\nHub removal ({hub}): {result}")
