#!/usr/bin/env python3
"""
Algorithms for Conceptual Dependency Critical Path Analysis

Implements:
  - DepGraph: Finite directed acyclic graph with predecessor map
  - compute_depth: O(V+E) topological depth computation
  - layered_discovery: Iterative BFS-like discovery from seed set
  - critical_path: Extract a longest path in the DAG
  - weighted variants: WDepGraph, weighted_depth, weighted_critical_path
"""

from __future__ import annotations
from collections import defaultdict, deque
from typing import Any, Dict, List, Optional, Set, Tuple


class DepGraph:
    """
    A finite directed acyclic graph represented by a predecessor map.

    Parameters
    ----------
    pred : dict mapping node -> list of predecessor nodes

    Examples
    --------
    >>> G = DepGraph({'a': [], 'b': ['a'], 'c': ['a', 'b']})
    >>> G.nodes
    {'a', 'b', 'c'}
    >>> G.pred['c']
    ['a', 'b']
    """

    def __init__(self, pred: Dict[Any, List[Any]]):
        self.pred = {k: list(v) for k, v in pred.items()}
        self.nodes = set(pred.keys())
        # Build successor map
        self.succ: Dict[Any, List[Any]] = defaultdict(list)
        for v, preds in self.pred.items():
            for u in preds:
                self.succ[u].append(v)
        # Verify acyclicity
        self._verify_acyclic()

    def _verify_acyclic(self):
        """Verify the graph is acyclic using Kahn's algorithm."""
        in_degree = {v: len(self.pred[v]) for v in self.nodes}
        queue = deque(v for v in self.nodes if in_degree[v] == 0)
        count = 0
        while queue:
            v = queue.popleft()
            count += 1
            for u in self.succ.get(v, []):
                in_degree[u] -= 1
                if in_degree[u] == 0:
                    queue.append(u)
        if count != len(self.nodes):
            raise ValueError("Graph contains a cycle!")

    def sources(self) -> Set[Any]:
        """Return the set of source nodes (no predecessors)."""
        return {v for v in self.nodes if not self.pred[v]}

    def topological_order(self) -> List[Any]:
        """Return a topological ordering of the nodes."""
        in_degree = {v: len(self.pred[v]) for v in self.nodes}
        queue = deque(v for v in self.nodes if in_degree[v] == 0)
        order = []
        while queue:
            v = queue.popleft()
            order.append(v)
            for u in self.succ.get(v, []):
                in_degree[u] -= 1
                if in_degree[u] == 0:
                    queue.append(u)
        return order


def compute_depth(G: DepGraph) -> Dict[Any, int]:
    """
    Compute the conceptual depth of every node.

    depth(v) = 0 if v is a source
    depth(v) = 1 + max(depth(u) for u in pred(v)) otherwise

    Time: O(|V| + |E|)
    Space: O(|V|)

    Parameters
    ----------
    G : DepGraph

    Returns
    -------
    dict mapping node -> depth (int)

    Examples
    --------
    >>> G = DepGraph({'a': [], 'b': ['a'], 'c': ['b']})
    >>> compute_depth(G)
    {'a': 0, 'b': 1, 'c': 2}
    """
    depth = {}
    for v in G.topological_order():
        if not G.pred[v]:
            depth[v] = 0
        else:
            depth[v] = 1 + max(depth[u] for u in G.pred[v])
    return depth


def layered_discovery(G: DepGraph, seeds: Set[Any]) -> Dict[Any, int]:
    """
    Perform layered discovery from a seed set.

    Round 0: discover seeds.
    Round n+1: discover nodes whose predecessors are all discovered.

    Parameters
    ----------
    G : DepGraph
    seeds : set of seed nodes (should be sources for theorem guarantees)

    Returns
    -------
    dict mapping node -> discovery round (int)

    Examples
    --------
    >>> G = DepGraph({'a': [], 'b': ['a'], 'c': ['b']})
    >>> layered_discovery(G, {'a'})
    {'a': 0, 'b': 1, 'c': 2}
    """
    discovered = dict()
    current = set(seeds)
    for v in current:
        discovered[v] = 0

    round_num = 0
    while len(discovered) < len(G.nodes):
        round_num += 1
        next_layer = set()
        for v in G.nodes - set(discovered.keys()):
            if all(u in discovered for u in G.pred[v]):
                next_layer.add(v)
        if not next_layer:
            break  # remaining nodes unreachable from seeds
        for v in next_layer:
            discovered[v] = round_num
        current = next_layer

    return discovered


def critical_path(G: DepGraph, depth: Optional[Dict[Any, int]] = None) -> List[Any]:
    """
    Extract a critical path (longest path from source to deepest node).

    Parameters
    ----------
    G : DepGraph
    depth : optional precomputed depth dict

    Returns
    -------
    list of nodes forming the critical path

    Examples
    --------
    >>> G = DepGraph({'a': [], 'b': ['a'], 'c': ['b']})
    >>> critical_path(G)
    ['a', 'b', 'c']
    """
    if depth is None:
        depth = compute_depth(G)

    # Find deepest node
    target = max(depth, key=depth.get)

    # Trace back from target
    path = [target]
    current = target
    while depth[current] > 0:
        # Find predecessor with depth = current depth - 1
        for u in G.pred[current]:
            if depth[u] == depth[current] - 1:
                path.append(u)
                current = u
                break
    path.reverse()
    return path


def critical_path_length(G: DepGraph) -> int:
    """Compute the critical path length of the DAG."""
    depth = compute_depth(G)
    return max(depth.values()) if depth else 0


# ============================================================
# Weighted extensions
# ============================================================

class WDepGraph(DepGraph):
    """
    A weighted dependency graph where each node has a conceptual novelty cost.

    Parameters
    ----------
    pred : dict mapping node -> list of predecessors
    weight : dict mapping node -> weight (positive integer)
    """

    def __init__(self, pred: Dict[Any, List[Any]], weight: Dict[Any, int]):
        super().__init__(pred)
        self.weight = weight
        for v in self.nodes:
            assert weight.get(v, 1) >= 1, f"Weight of {v} must be positive"


def weighted_depth(G: WDepGraph) -> Dict[Any, int]:
    """
    Compute weighted depth: max sum of weights along any path to v.

    wdepth(v) = w(v) if v is a source
    wdepth(v) = w(v) + max(wdepth(u) for u in pred(v)) otherwise

    Parameters
    ----------
    G : WDepGraph

    Returns
    -------
    dict mapping node -> weighted depth
    """
    wdepth = {}
    for v in G.topological_order():
        if not G.pred[v]:
            wdepth[v] = G.weight.get(v, 1)
        else:
            wdepth[v] = G.weight.get(v, 1) + max(wdepth[u] for u in G.pred[v])
    return wdepth


def weighted_critical_path(G: WDepGraph) -> Tuple[List[Any], int]:
    """
    Extract the weighted critical path and its total weight.

    Returns
    -------
    (path, total_weight) where path is a list of nodes
    """
    wd = weighted_depth(G)
    target = max(wd, key=wd.get)
    total = wd[target]

    path = [target]
    current = target
    while G.pred[current]:
        best_pred = max(G.pred[current], key=lambda u: wd[u])
        path.append(best_pred)
        current = best_pred

    path.reverse()
    return path, total


if __name__ == '__main__':
    # Quick self-test
    G = DepGraph({'a': [], 'b': [], 'c': ['a'], 'd': ['a', 'b'], 'e': ['c', 'd']})
    d = compute_depth(G)
    print("Depth:", d)
    print("Critical path:", critical_path(G, d))
    print("Discovery:", layered_discovery(G, G.sources()))
    print("Critical path length:", critical_path_length(G))

    # Weighted example
    WG = WDepGraph(
        {'a': [], 'b': [], 'c': ['a'], 'd': ['a', 'b'], 'e': ['c', 'd']},
        {'a': 1, 'b': 1, 'c': 3, 'd': 1, 'e': 2}
    )
    print("\nWeighted depth:", weighted_depth(WG))
    wp, wt = weighted_critical_path(WG)
    print(f"Weighted critical path: {wp} (total weight: {wt})")
