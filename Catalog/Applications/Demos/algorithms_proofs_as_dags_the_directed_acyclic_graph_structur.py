#!/usr/bin/env python3
"""
Algorithms for Proof DAG Analysis

Type-hinted implementations of the key algorithms from the
Stratified Dependency Algebra framework.
"""

from __future__ import annotations
from collections import defaultdict, deque
from dataclasses import dataclass, field
from typing import Dict, FrozenSet, List, Optional, Set, Tuple


@dataclass
class FinDAG:
    """A finite directed acyclic graph.

    Attributes:
        nodes: Set of node identifiers.
        edges: Set of directed edges (u, v) meaning u → v.
    """
    nodes: FrozenSet[str]
    edges: FrozenSet[Tuple[str, str]]
    _adj: Dict[str, List[str]] = field(default_factory=dict, repr=False)
    _radj: Dict[str, List[str]] = field(default_factory=dict, repr=False)

    def __post_init__(self) -> None:
        self._adj = defaultdict(list)
        self._radj = defaultdict(list)
        for u, v in self.edges:
            self._adj[u].append(v)
            self._radj[v].append(u)
        # Verify acyclicity
        assert self.is_acyclic(), "Graph contains a cycle!"

    def is_acyclic(self) -> bool:
        """Check acyclicity using Kahn's algorithm."""
        in_deg = {n: 0 for n in self.nodes}
        for _, v in self.edges:
            in_deg[v] = in_deg.get(v, 0) + 1
        queue = deque(n for n in self.nodes if in_deg[n] == 0)
        count = 0
        while queue:
            node = queue.popleft()
            count += 1
            for neighbor in self._adj.get(node, []):
                in_deg[neighbor] -= 1
                if in_deg[neighbor] == 0:
                    queue.append(neighbor)
        return count == len(self.nodes)

    def successors(self, v: str) -> List[str]:
        return self._adj.get(v, [])

    def predecessors(self, v: str) -> List[str]:
        return self._radj.get(v, [])


def compute_reach_sets(dag: FinDAG) -> Dict[str, Set[str]]:
    """Compute R(v) = {w : v →⁺ w} for all v.

    Algorithm: Process nodes in reverse topological order.
    R(v) = ⋃_{w: v→w} ({w} ∪ R(w))

    Time: O(n²) in the worst case.
    Space: O(n²) for storing all reach sets.
    """
    # Topological sort
    topo_order = topological_sort(dag)

    reach: Dict[str, Set[str]] = {n: set() for n in dag.nodes}
    for v in reversed(topo_order):
        for w in dag.successors(v):
            reach[v].add(w)
            reach[v].update(reach[w])

    return reach


def hub_scores(dag: FinDAG) -> Dict[str, int]:
    """Compute hub score h(v) = |R(v)| for all nodes.

    Returns a dictionary mapping nodes to their hub scores.
    The Hub Monotonicity Theorem guarantees: if (u,v) ∈ E then h(u) > h(v).
    """
    reach = compute_reach_sets(dag)
    return {v: len(reach[v]) for v in dag.nodes}


def topological_sort(dag: FinDAG) -> List[str]:
    """Compute a topological ordering of the DAG.

    Returns nodes in order such that for every edge (u,v), u appears before v.
    """
    in_deg = {n: 0 for n in dag.nodes}
    for _, v in dag.edges:
        in_deg[v] = in_deg.get(v, 0) + 1
    queue = deque(sorted(n for n in dag.nodes if in_deg[n] == 0))
    result: List[str] = []
    while queue:
        node = queue.popleft()
        result.append(node)
        for neighbor in sorted(dag.successors(node)):
            in_deg[neighbor] -= 1
            if in_deg[neighbor] == 0:
                queue.append(neighbor)
    return result


def canonical_stratification(dag: FinDAG) -> Dict[str, int]:
    """Compute the canonical (minimum) stratification.

    σ(v) = 0 if v is a source, else σ(v) = 1 + max{σ(u) : (u,v) ∈ E}.

    The Stratum Transitivity Theorem guarantees:
    if u →⁺ v then σ(u) < σ(v).
    """
    topo = topological_sort(dag)
    stratum: Dict[str, int] = {}
    for v in topo:
        preds = dag.predecessors(v)
        if not preds:
            stratum[v] = 0
        else:
            stratum[v] = 1 + max(stratum[p] for p in preds)
    return stratum


def find_sources(dag: FinDAG) -> List[str]:
    """Find all sources (nodes with in-degree 0).

    Source Existence Theorem guarantees at least one exists
    for non-empty DAGs.
    """
    return sorted(v for v in dag.nodes if not dag.predecessors(v))


def find_sinks(dag: FinDAG) -> List[str]:
    """Find all sinks (nodes with out-degree 0).

    Sink Existence Theorem guarantees at least one exists
    for non-empty DAGs.
    """
    return sorted(v for v in dag.nodes if not dag.successors(v))


def transitive_closure_size(dag: FinDAG) -> int:
    """Compute |TC| = |{(a,b) : a →⁺ b}|.

    Hub Score Sum Identity: Σ h(v) = |TC|.
    """
    reach = compute_reach_sets(dag)
    return sum(len(r) for r in reach.values())


def compute_fragility(dag: FinDAG, v: str) -> int:
    """Compute the fragility of node v.

    Fragility = number of nodes made unreachable from all sources
    when v is removed from the DAG.
    """
    sources = find_sources(dag)

    # Build reduced DAG (without v)
    reduced_nodes = frozenset(n for n in dag.nodes if n != v)
    reduced_edges = frozenset((u, w) for u, w in dag.edges if u != v and w != v)
    if not reduced_nodes:
        return 0

    reduced_adj: Dict[str, List[str]] = defaultdict(list)
    for u, w in reduced_edges:
        reduced_adj[u].append(w)

    # Find nodes reachable from sources in reduced graph
    reachable: Set[str] = set()
    for s in sources:
        if s == v:
            continue
        queue = deque([s])
        reachable.add(s)
        while queue:
            node = queue.popleft()
            for neighbor in reduced_adj.get(node, []):
                if neighbor not in reachable:
                    reachable.add(neighbor)
                    queue.append(neighbor)

    return len(reduced_nodes - reachable)


def in_degree_distribution(dag: FinDAG) -> Dict[int, int]:
    """Compute the in-degree distribution P(k) = #{nodes with in-degree k}."""
    in_degs: Dict[str, int] = {n: 0 for n in dag.nodes}
    for _, v in dag.edges:
        in_degs[v] = in_degs.get(v, 0) + 1
    dist: Dict[int, int] = defaultdict(int)
    for d in in_degs.values():
        dist[d] += 1
    return dict(dist)


def hub_score_distribution(dag: FinDAG) -> Dict[int, int]:
    """Compute the hub score distribution P(h) = #{nodes with hub score h}."""
    scores = hub_scores(dag)
    dist: Dict[int, int] = defaultdict(int)
    for h in scores.values():
        dist[h] += 1
    return dict(dist)


def verify_hub_monotonicity(dag: FinDAG) -> bool:
    """Verify the Hub Monotonicity Theorem: for all edges (u,v), h(u) > h(v).

    This should ALWAYS return True for a valid DAG (it's a theorem!).
    """
    scores = hub_scores(dag)
    for u, v in dag.edges:
        if scores[u] <= scores[v]:
            return False
    return True


def verify_sum_identity(dag: FinDAG) -> bool:
    """Verify the Hub Score Sum Identity: Σ h(v) = |TC|."""
    scores = hub_scores(dag)
    tc = transitive_closure_size(dag)
    return sum(scores.values()) == tc


# --- Example usage ---

if __name__ == "__main__":
    # Build a sample proof DAG
    nodes = frozenset(["Ax1", "Ax2", "L1", "L2", "L3", "T1", "T2"])
    edges = frozenset([
        ("Ax1", "L1"), ("Ax1", "L2"),
        ("Ax2", "L2"), ("Ax2", "L3"),
        ("L1", "T1"), ("L2", "T1"), ("L2", "T2"), ("L3", "T2"),
    ])
    dag = FinDAG(nodes=nodes, edges=edges)

    print("=== Proof DAG Analysis ===")
    print(f"Nodes: {sorted(dag.nodes)}")
    print(f"Edges: {sorted(dag.edges)}")
    print(f"\nSources: {find_sources(dag)}")
    print(f"Sinks: {find_sinks(dag)}")
    print(f"\nHub Scores: {hub_scores(dag)}")
    print(f"Stratification: {canonical_stratification(dag)}")
    print(f"\nTC Size: {transitive_closure_size(dag)}")
    print(f"Sum of hub scores: {sum(hub_scores(dag).values())}")
    print(f"Sum Identity verified: {verify_sum_identity(dag)}")
    print(f"Monotonicity verified: {verify_hub_monotonicity(dag)}")
    print(f"\nFragility:")
    for v in sorted(dag.nodes):
        print(f"  fragility({v}) = {compute_fragility(dag, v)}")
