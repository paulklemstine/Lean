#!/usr/bin/env python3
"""
Algorithms for Conceptual Dependency Critical Path Theory

Implements the core algorithms from the formalization:
- DepGraph: finite directed acyclic graph with predecessor maps
- depth computation via well-founded recursion
- layered discovery process
- critical path computation
- topological sorting
- bottleneck detection

All algorithms include docstrings, type hints, and complexity analysis.
"""

from __future__ import annotations
from typing import Dict, List, Set, Optional, Tuple
from functools import lru_cache
from collections import deque


class DepGraph:
    """
    A finite directed acyclic graph represented by a predecessor map.

    Mirrors the Lean structure:
        structure DepGraph (V : Type*) where
          pred : V → Finset V
          wf : WellFounded (fun u v => u ∈ pred v)

    Time complexity:
        - Construction: O(|V| + |E|) where |E| = total predecessor count
        - depth(v): O(|V| + |E|) with memoization
        - source_set(): O(|V|)

    Space complexity: O(|V| + |E|)
    """

    def __init__(self, nodes: List[str], pred: Dict[str, List[str]]):
        """
        Args:
            nodes: List of node identifiers
            pred: Map from node to list of immediate predecessors
        """
        self.nodes = list(nodes)
        self.pred = {v: list(pred.get(v, [])) for v in nodes}
        self._depth_cache: Dict[str, int] = {}

        # Validate acyclicity
        if not self._is_acyclic():
            raise ValueError("Graph contains a cycle — not a valid dependency DAG")

    def _is_acyclic(self) -> bool:
        """Check acyclicity via topological sort (Kahn's algorithm). O(|V|+|E|)."""
        in_degree = {v: len(self.pred[v]) for v in self.nodes}
        queue = deque(v for v in self.nodes if in_degree[v] == 0)
        count = 0
        temp_in = dict(in_degree)

        # Build successor map
        succ: Dict[str, List[str]] = {v: [] for v in self.nodes}
        for v in self.nodes:
            for u in self.pred[v]:
                succ[u].append(v)

        while queue:
            v = queue.popleft()
            count += 1
            for w in succ[v]:
                temp_in[w] -= 1
                if temp_in[w] == 0:
                    queue.append(w)

        return count == len(self.nodes)

    def depth(self, v: str) -> int:
        """
        Compute the depth of node v.

        Corresponds to:
            noncomputable def depth (G : DepGraph V) : V → ℕ :=
              G.wf.fix fun v ih =>
                if h : G.pred v = ∅ then 0
                else (G.pred v).attach.sup (fun ⟨u, hu⟩ => ih u hu) + 1

        Returns:
            0 if v has no predecessors, otherwise 1 + max(depth of predecessors)

        Time: O(|V| + |E|) total with memoization
        """
        if v in self._depth_cache:
            return self._depth_cache[v]

        if not self.pred[v]:
            self._depth_cache[v] = 0
            return 0

        d = 1 + max(self.depth(u) for u in self.pred[v])
        self._depth_cache[v] = d
        return d

    def is_source(self, v: str) -> bool:
        """Check if v is a source (no predecessors)."""
        return len(self.pred[v]) == 0

    def source_set(self) -> Set[str]:
        """Return the set of all source nodes. O(|V|)."""
        return {v for v in self.nodes if self.is_source(v)}

    def successors(self, v: str) -> List[str]:
        """Return nodes that have v as a predecessor. O(|V| + |E|)."""
        return [w for w in self.nodes if v in self.pred[w]]

    def topological_sort(self) -> List[str]:
        """
        Return a topological ordering of nodes. O(|V| + |E|).

        Nodes appear before all their dependents.
        """
        in_degree = {v: len(self.pred[v]) for v in self.nodes}
        succ: Dict[str, List[str]] = {v: [] for v in self.nodes}
        for v in self.nodes:
            for u in self.pred[v]:
                succ[u].append(v)

        queue = deque(v for v in self.nodes if in_degree[v] == 0)
        result = []

        while queue:
            v = queue.popleft()
            result.append(v)
            for w in succ[v]:
                in_degree[w] -= 1
                if in_degree[w] == 0:
                    queue.append(w)

        return result

    def all_ancestors(self, v: str) -> Set[str]:
        """Return all transitive predecessors of v (not including v). O(|V| + |E|)."""
        visited: Set[str] = set()
        stack = list(self.pred[v])
        while stack:
            u = stack.pop()
            if u not in visited:
                visited.add(u)
                stack.extend(self.pred[u])
        return visited

    def critical_path(self, v: str) -> List[str]:
        """
        Return a longest path ending at v (witnesses the depth).
        O(depth(v) * max_predecessors)
        """
        if not self.pred[v]:
            return [v]

        # Find predecessor with maximum depth
        best_pred = max(self.pred[v], key=lambda u: self.depth(u))
        return self.critical_path(best_pred) + [v]

    def bottleneck_nodes(self) -> List[str]:
        """
        Find bottleneck nodes: nodes that lie on every longest path.
        A node is a bottleneck if removing it would reduce the critical path length.
        O(|V| * (|V| + |E|))
        """
        cpl = critical_path_length(self)
        bottlenecks = []

        for v in self.nodes:
            # Create graph without v
            remaining = [u for u in self.nodes if u != v]
            new_pred = {}
            for u in remaining:
                new_pred[u] = [w for w in self.pred[u] if w != v]

            if remaining:
                try:
                    G_minus_v = DepGraph(remaining, new_pred)
                    new_cpl = critical_path_length(G_minus_v)
                    if new_cpl < cpl:
                        bottlenecks.append(v)
                except ValueError:
                    pass

        return bottlenecks


def next_layer(G: DepGraph, discovered: Set[str]) -> Set[str]:
    """
    Compute the next layer of discoverable nodes.

    Corresponds to:
        def nextLayer (G : DepGraph V) (A : Finset V) : Finset V :=
          Finset.univ.filter (fun v => v ∉ A ∧ ∀ u ∈ G.pred v, u ∈ A)

    Args:
        G: The dependency graph
        discovered: Set of already-discovered nodes

    Returns:
        Set of newly discoverable nodes (predecessors all in `discovered`)

    Time: O(|V| + |E|)
    """
    layer = set()
    for v in G.nodes:
        if v not in discovered:
            if all(u in discovered for u in G.pred[v]):
                layer.add(v)
    return layer


def layered_discovery(G: DepGraph, seeds: Set[str], rounds: int) -> Set[str]:
    """
    Perform layered discovery for a given number of rounds.

    Corresponds to:
        def discovered (G : DepGraph V) (S : Finset V) : ℕ → Finset V
          | 0 => S
          | n + 1 => G.discovered S n ∪ G.nextLayer (G.discovered S n)

    Args:
        G: The dependency graph
        seeds: Initial seed set (should be sources)
        rounds: Number of discovery rounds

    Returns:
        Set of all discovered nodes after `rounds` rounds

    Time: O(rounds * (|V| + |E|))
    """
    disc = set(seeds)
    for _ in range(rounds):
        disc = disc | next_layer(G, disc)
    return disc


def critical_path_length(G: DepGraph) -> int:
    """
    Compute the critical path length (maximum depth over all nodes).

    Corresponds to:
        noncomputable def criticalPathLength (G : DepGraph V) : ℕ :=
          Finset.univ.sup G.depth

    Time: O(|V| + |E|) with memoized depth
    """
    if not G.nodes:
        return 0
    return max(G.depth(v) for v in G.nodes)


def find_all_critical_paths(G: DepGraph) -> List[List[str]]:
    """
    Find all longest paths in the DAG.

    Returns:
        List of all paths achieving the critical path length.

    Time: O(|V| * |E|) worst case
    """
    cpl = critical_path_length(G)

    def paths_to(v: str, target_len: int) -> List[List[str]]:
        if target_len == 0:
            return [[v]] if G.depth(v) == 0 else []
        if G.depth(v) != target_len:
            return []
        result = []
        for u in G.pred[v]:
            for path in paths_to(u, target_len - 1):
                result.append(path + [v])
        return result

    all_paths = []
    for v in G.nodes:
        if G.depth(v) == cpl:
            all_paths.extend(paths_to(v, cpl))
    return all_paths


def verify_theorem_A1(G: DepGraph) -> bool:
    """
    Verify Theorem A1: for all v discovered by round n, depth(v) ≤ n.

    This is a computational verification of:
        theorem mem_discovered_imp_depth_le
    """
    sources = G.source_set()
    cpl = critical_path_length(G)

    for n in range(cpl + 2):
        disc = layered_discovery(G, sources, n)
        for v in disc:
            if G.depth(v) > n:
                return False
    return True


def verify_theorem_B2(G: DepGraph) -> bool:
    """
    Verify Theorem B2: for k < CPL, ∃ v not discovered in k rounds.

    This is a computational verification of:
        theorem exists_not_mem_discovered_of_lt_criticalPath
    """
    sources = G.source_set()
    cpl = critical_path_length(G)

    for k in range(cpl):
        disc = layered_discovery(G, sources, k)
        if disc == set(G.nodes):
            return False  # Should have missed something
    return True


def verify_theorem_C1(G: DepGraph) -> bool:
    """
    Verify Theorem C1: after CPL rounds from sources, all nodes discovered.

    This is a computational verification of:
        theorem discovered_eq_univ_at_criticalPath
    """
    sources = G.source_set()
    cpl = critical_path_length(G)
    disc = layered_discovery(G, sources, cpl)
    return disc == set(G.nodes)


# Example usage
if __name__ == "__main__":
    # Build a sample dependency graph
    nodes = ["Axiom1", "Axiom2", "Lemma1", "Lemma2", "Lemma3", "Theorem1"]
    pred = {
        "Axiom1": [],
        "Axiom2": [],
        "Lemma1": ["Axiom1"],
        "Lemma2": ["Axiom1", "Axiom2"],
        "Lemma3": ["Lemma1", "Lemma2"],
        "Theorem1": ["Lemma3"],
    }

    G = DepGraph(nodes, pred)
    print("Dependency Graph:")
    print(f"  Nodes: {G.nodes}")
    print(f"  Sources: {G.source_set()}")
    print(f"  Critical path length: {critical_path_length(G)}")
    print(f"  Depths: {[(v, G.depth(v)) for v in nodes]}")
    print(f"  Topological sort: {G.topological_sort()}")
    print(f"  Critical path to Theorem1: {G.critical_path('Theorem1')}")
    print(f"  Bottleneck nodes: {G.bottleneck_nodes()}")
    print()

    # Verify all theorems
    print("Theorem verification:")
    print(f"  A1 (depth lower bound):     {'✓' if verify_theorem_A1(G) else '✗'}")
    print(f"  B2 (shallow search fails):  {'✓' if verify_theorem_B2(G) else '✗'}")
    print(f"  C1 (guided completeness):   {'✓' if verify_theorem_C1(G) else '✗'}")
