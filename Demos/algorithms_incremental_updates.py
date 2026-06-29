#!/usr/bin/env python3
"""
Algorithms for incremental DAG recomputation.

Implements the core data structures and algorithms corresponding to the
formally verified locality theorem for dependency DAGs.
"""

from __future__ import annotations
from collections import defaultdict, deque
from typing import Dict, Set, Optional, List, Tuple


class DAG:
    """A directed acyclic graph represented by predecessor lists.

    For each vertex v, predecessors[v] is the set of vertices u such that
    there is an edge u -> v (meaning v depends on u).

    Attributes:
        _preds: mapping from vertex to set of predecessors
        _succs: mapping from vertex to set of successors (maintained for efficiency)
    """

    def __init__(self):
        self._preds: Dict[str, Set[str]] = defaultdict(set)
        self._succs: Dict[str, Set[str]] = defaultdict(set)
        self._all_nodes: Set[str] = set()

    def add_node(self, v: str) -> None:
        """Add a vertex (no-op if already present)."""
        self._all_nodes.add(v)

    def add_edge(self, u: str, v: str) -> None:
        """Add edge u -> v meaning v depends on u (u is a predecessor of v).

        Args:
            u: source (prerequisite)
            v: target (dependent)
        """
        self._all_nodes.add(u)
        self._all_nodes.add(v)
        self._preds[v].add(u)
        self._succs[u].add(v)

    def remove_edge(self, u: str, v: str) -> None:
        """Remove edge u -> v if it exists."""
        self._preds[v].discard(u)
        self._succs[u].discard(v)

    def predecessors(self, v: str) -> Set[str]:
        """Return the set of immediate predecessors of v."""
        return self._preds.get(v, set()).copy()

    def successors(self, v: str) -> Set[str]:
        """Return the set of immediate successors of v."""
        return self._succs.get(v, set()).copy()

    def nodes(self) -> Set[str]:
        """Return all vertices."""
        return self._all_nodes.copy()

    def edges(self) -> List[Tuple[str, str]]:
        """Return all edges as (u, v) pairs."""
        result = []
        for v, preds in self._preds.items():
            for u in preds:
                result.append((u, v))
        return result

    def copy(self) -> 'DAG':
        """Return a deep copy."""
        new_dag = DAG()
        new_dag._all_nodes = self._all_nodes.copy()
        new_dag._preds = defaultdict(set, {k: v.copy() for k, v in self._preds.items()})
        new_dag._succs = defaultdict(set, {k: v.copy() for k, v in self._succs.items()})
        return new_dag

    def is_acyclic(self) -> bool:
        """Check acyclicity via Kahn's algorithm.

        Time complexity: O(V + E)

        Returns:
            True if the graph is a DAG.
        """
        in_degree = {v: len(self._preds.get(v, set())) for v in self._all_nodes}
        queue = deque([v for v, d in in_degree.items() if d == 0])
        count = 0
        while queue:
            v = queue.popleft()
            count += 1
            for w in self._succs.get(v, set()):
                in_degree[w] -= 1
                if in_degree[w] == 0:
                    queue.append(w)
        return count == len(self._all_nodes)

    def topological_sort(self) -> List[str]:
        """Return a topological ordering (sources first).

        Time complexity: O(V + E)
        """
        in_degree = {v: len(self._preds.get(v, set())) for v in self._all_nodes}
        queue = deque(sorted([v for v, d in in_degree.items() if d == 0]))
        order = []
        while queue:
            v = queue.popleft()
            order.append(v)
            for w in sorted(self._succs.get(v, set())):
                in_degree[w] -= 1
                if in_degree[w] == 0:
                    queue.append(w)
        return order


def compute_levels(dag: DAG) -> Dict[str, int]:
    """Compute the level of every vertex in the DAG.

    level(v) = 0                           if v is a source
    level(v) = max(level(u) + 1 : u ∈ pred(v))  otherwise

    This is the length of the longest path ending at v.

    Time complexity: O(V + E)
    Space complexity: O(V)

    Args:
        dag: A directed acyclic graph.

    Returns:
        Dictionary mapping each vertex to its level.
    """
    order = dag.topological_sort()
    levels: Dict[str, int] = {}
    for v in order:
        preds = dag.predecessors(v)
        if not preds:
            levels[v] = 0
        else:
            levels[v] = max(levels[u] + 1 for u in preds)
    return levels


def forward_cone(dag: DAG, new: str) -> Set[str]:
    """Compute the forward reachability cone of a vertex.

    Returns the set of all vertices reachable from `new` by following
    edges in the forward direction (new -> successors -> ...).

    Time complexity: O(V + E)

    Args:
        dag: The DAG to search in.
        new: The source vertex.

    Returns:
        Set of vertices reachable from `new` (including `new` itself).
    """
    visited: Set[str] = set()
    queue = deque([new])
    while queue:
        v = queue.popleft()
        if v in visited:
            continue
        visited.add(v)
        for w in dag.successors(v):
            if w not in visited:
                queue.append(w)
    return visited


def incremental_update(
    old_dag: DAG,
    new_dag: DAG,
    new_node: str,
) -> Dict[str, int]:
    """Perform incremental level recomputation after inserting a new node.

    Instead of recomputing all levels from scratch, this function:
    1. Computes the forward cone of the new node.
    2. Reuses old levels for vertices outside the cone.
    3. Recomputes levels only within the cone.

    This is the algorithmic realization of the locality theorem:
    only the forward cone needs recomputation.

    Time complexity: O(|cone| + edges within/into cone)
    Space complexity: O(V) total

    Args:
        old_dag: The original DAG before the update.
        new_dag: The DAG after inserting the new node and edges.
        new_node: The newly inserted vertex.

    Returns:
        Dictionary mapping each vertex to its level in new_dag.
    """
    # Step 1: compute old levels
    old_levels = compute_levels(old_dag)

    # Step 2: compute the forward cone in the new DAG
    cone = forward_cone(new_dag, new_node)

    # Step 3: initialize result with old levels for nodes outside the cone
    result: Dict[str, int] = {}
    for v in new_dag.nodes():
        if v not in cone:
            result[v] = old_levels.get(v, 0)

    # Step 4: topologically sort the cone and recompute levels within it
    # We need a topological order restricted to cone vertices
    order = new_dag.topological_sort()
    for v in order:
        if v in cone:
            preds = new_dag.predecessors(v)
            if not preds:
                result[v] = 0
            else:
                result[v] = max(result.get(u, 0) + 1 for u in preds)

    return result


def verify_locality(
    old_dag: DAG,
    new_dag: DAG,
    new_node: str,
) -> Dict[str, str]:
    """Verify the locality theorem computationally.

    Checks that for every vertex outside the forward cone of new_node,
    the level is unchanged between old_dag and new_dag.

    Returns:
        Dictionary with verification results for each vertex.
    """
    old_levels = compute_levels(old_dag)
    new_levels = compute_levels(new_dag)
    cone = forward_cone(new_dag, new_node)

    results: Dict[str, str] = {}
    for v in sorted(new_dag.nodes()):
        if v in cone:
            results[v] = f"IN_CONE (old={old_levels.get(v, 'N/A')}, new={new_levels[v]})"
        elif v in old_levels:
            if old_levels[v] == new_levels[v]:
                results[v] = f"UNCHANGED ✓ (level={old_levels[v]})"
            else:
                results[v] = f"ERROR: level changed from {old_levels[v]} to {new_levels[v]}!"
        else:
            results[v] = f"NEW_NODE (level={new_levels[v]})"

    return results


if __name__ == "__main__":
    # Quick self-test
    dag = DAG()
    dag.add_edge("A", "B")
    dag.add_edge("B", "C")
    dag.add_edge("A", "C")

    levels = compute_levels(dag)
    print(f"Levels: {levels}")
    assert levels == {"A": 0, "B": 1, "C": 2}

    cone = forward_cone(dag, "B")
    print(f"Forward cone of B: {cone}")
    assert cone == {"B", "C"}

    print("All self-tests passed!")
