#!/usr/bin/env python3
"""
Algorithms for Proof DAG Analysis

Type-hinted implementations of the core algorithms from the research:
1. Hub score computation
2. Fragility analysis
3. Topological ordering
4. Power law fitting (Clauset-Shalizi-Newman method)
5. Source/sink identification
"""

from __future__ import annotations
from typing import Dict, List, Set, Tuple, Optional
import math
import random


def compute_hub_scores(
    nodes: List[str],
    edges: List[Tuple[str, str]]
) -> Dict[str, Dict[str, float]]:
    """
    Compute hub metrics for all nodes in a DAG.

    Args:
        nodes: List of node identifiers
        edges: List of (source, target) directed edges

    Returns:
        Dict mapping each node to its metrics:
        {node: {"out_degree": int, "in_degree": int,
                "fragility": float, "is_source": bool, "is_sink": bool}}
    """
    n = len(nodes)
    m = len(edges)

    out_deg: Dict[str, int] = {v: 0 for v in nodes}
    in_deg: Dict[str, int] = {v: 0 for v in nodes}

    for a, b in edges:
        out_deg[a] += 1
        in_deg[b] += 1

    result: Dict[str, Dict[str, float]] = {}
    for v in nodes:
        result[v] = {
            "out_degree": out_deg[v],
            "in_degree": in_deg[v],
            "fragility": out_deg[v] / m if m > 0 else 0.0,
            "is_source": in_deg[v] == 0,
            "is_sink": out_deg[v] == 0,
        }

    return result


def topological_sort(
    nodes: List[str],
    edges: List[Tuple[str, str]]
) -> List[str]:
    """
    Compute a topological ordering of a DAG using Kahn's algorithm.

    Args:
        nodes: List of node identifiers
        edges: List of (source, target) directed edges

    Returns:
        Topologically sorted list of nodes

    Raises:
        ValueError: If the graph contains a cycle
    """
    adj: Dict[str, List[str]] = {n: [] for n in nodes}
    in_deg: Dict[str, int] = {n: 0 for n in nodes}

    for a, b in edges:
        adj[a].append(b)
        in_deg[b] += 1

    queue = [n for n in nodes if in_deg[n] == 0]
    result: List[str] = []

    while queue:
        v = queue.pop(0)
        result.append(v)
        for w in adj[v]:
            in_deg[w] -= 1
            if in_deg[w] == 0:
                queue.append(w)

    if len(result) != len(nodes):
        raise ValueError("Graph contains a cycle")

    return result


def compute_node_depths(
    nodes: List[str],
    edges: List[Tuple[str, str]]
) -> Dict[str, int]:
    """
    Compute the depth of each node: length of longest path from any source.

    Args:
        nodes: List of node identifiers
        edges: List of (source, target) directed edges

    Returns:
        Dict mapping each node to its depth
    """
    order = topological_sort(nodes, edges)
    depth: Dict[str, int] = {v: 0 for v in nodes}

    adj: Dict[str, List[str]] = {n: [] for n in nodes}
    for a, b in edges:
        adj[a].append(b)

    for v in order:
        for w in adj[v]:
            depth[w] = max(depth[w], depth[v] + 1)

    return depth


def find_reachable_set(
    source: str,
    adj: Dict[str, List[str]]
) -> Set[str]:
    """
    Find all nodes reachable from source via BFS.

    Args:
        source: Starting node
        adj: Adjacency list

    Returns:
        Set of all reachable nodes (excluding source)
    """
    visited: Set[str] = set()
    queue = [source]

    while queue:
        v = queue.pop(0)
        for w in adj.get(v, []):
            if w not in visited:
                visited.add(w)
                queue.append(w)

    return visited


def fit_power_law_mle(
    degrees: List[int],
    x_min: Optional[int] = None
) -> Tuple[float, float]:
    """
    Fit a power law distribution using Maximum Likelihood Estimation.
    Uses the Clauset-Shalizi-Newman method.

    P(k) ~ k^{-gamma} for k >= x_min

    Args:
        degrees: List of degree values
        x_min: Minimum value for the power law fit.
               If None, uses the minimum positive degree.

    Returns:
        (gamma, x_min): Fitted exponent and minimum value
    """
    positive = [d for d in degrees if d > 0]
    if not positive:
        return (0.0, 0.0)

    if x_min is None:
        x_min = min(positive)

    filtered = [d for d in positive if d >= x_min]
    n = len(filtered)

    if n == 0:
        return (0.0, float(x_min))

    # MLE estimator: gamma = 1 + n * [sum ln(x_i / (x_min - 0.5))]^{-1}
    log_sum = sum(math.log(x / (x_min - 0.5)) for x in filtered)

    if log_sum <= 0:
        return (float('inf'), float(x_min))

    gamma = 1.0 + n / log_sum
    return (gamma, float(x_min))


def compute_fragility_entropy(
    nodes: List[str],
    edges: List[Tuple[str, str]]
) -> float:
    """
    Compute the Shannon entropy of the fragility distribution.

    H(f) = -sum fragility(v) * log(fragility(v))

    Args:
        nodes: List of node identifiers
        edges: List of (source, target) directed edges

    Returns:
        Shannon entropy in nats
    """
    m = len(edges)
    if m == 0:
        return 0.0

    scores = compute_hub_scores(nodes, edges)
    entropy = 0.0

    for v in nodes:
        f = scores[v]["fragility"]
        if f > 0:
            entropy -= f * math.log(f)

    return entropy


def hub_removal_analysis(
    nodes: List[str],
    edges: List[Tuple[str, str]],
    hub: str
) -> Dict[str, int]:
    """
    Analyze the effect of removing a hub node from the DAG.

    Args:
        nodes: List of node identifiers
        edges: List of (source, target) directed edges
        hub: Node to remove

    Returns:
        Dict with analysis results:
        {"edges_removed": int, "nodes_disconnected": int,
         "components_added": int}
    """
    remaining_nodes = [v for v in nodes if v != hub]
    remaining_edges = [(a, b) for a, b in edges if a != hub and b != hub]

    edges_removed = len(edges) - len(remaining_edges)

    # Count connected components (ignoring direction)
    parent: Dict[str, str] = {v: v for v in remaining_nodes}

    def find(x: str) -> str:
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x

    def union(x: str, y: str) -> None:
        px, py = find(x), find(y)
        if px != py:
            parent[px] = py

    for a, b in remaining_edges:
        union(a, b)

    components = len(set(find(v) for v in remaining_nodes))

    # Count nodes unreachable from any source after removal
    adj_after: Dict[str, List[str]] = {v: [] for v in remaining_nodes}
    in_deg_after: Dict[str, int] = {v: 0 for v in remaining_nodes}
    for a, b in remaining_edges:
        adj_after[a].append(b)
        in_deg_after[b] += 1

    sources_after = {v for v in remaining_nodes if in_deg_after[v] == 0}
    reachable: Set[str] = set()
    for s in sources_after:
        reachable |= find_reachable_set(s, adj_after)
        reachable.add(s)

    disconnected = len(remaining_nodes) - len(reachable)

    return {
        "edges_removed": edges_removed,
        "nodes_disconnected": disconnected,
        "components": components,
    }


def generate_preferential_attachment_dag(
    n: int,
    k: int = 2,
    seed: int = 42
) -> Tuple[List[str], List[Tuple[str, str]]]:
    """
    Generate a DAG using preferential attachment.

    At each step, a new node connects to k existing nodes with
    probability proportional to their out-degree + 1.

    Args:
        n: Number of nodes
        k: Edges per new node
        seed: Random seed

    Returns:
        (nodes, edges) tuple
    """
    rng = random.Random(seed)
    nodes = [f"N{i}" for i in range(n)]
    edges: List[Tuple[str, str]] = []
    out_deg: Dict[str, int] = {nodes[0]: 0}

    for i in range(1, n):
        existing = list(out_deg.keys())
        weights = [out_deg[v] + 1 for v in existing]
        total = sum(weights)
        probs = [w / total for w in weights]

        targets = set()
        attempts = 0
        while len(targets) < min(k, len(existing)) and attempts < 100:
            r = rng.random()
            cumsum = 0.0
            for j, p in enumerate(probs):
                cumsum += p
                if r < cumsum:
                    targets.add(existing[j])
                    break
            attempts += 1

        for t in targets:
            edges.append((t, nodes[i]))
            out_deg[t] += 1

        out_deg[nodes[i]] = 0

    return nodes, edges


if __name__ == "__main__":
    # Quick test
    nodes = ["A", "B", "C", "D", "E"]
    edges = [("A", "B"), ("A", "C"), ("B", "D"), ("C", "D"), ("D", "E")]

    scores = compute_hub_scores(nodes, edges)
    for v, s in scores.items():
        print(f"{v}: {s}")

    print(f"\nTopological order: {topological_sort(nodes, edges)}")
    print(f"Depths: {compute_node_depths(nodes, edges)}")
    print(f"Fragility entropy: {compute_fragility_entropy(nodes, edges):.4f}")
    print(f"Hub removal (A): {hub_removal_analysis(nodes, edges, 'A')}")
