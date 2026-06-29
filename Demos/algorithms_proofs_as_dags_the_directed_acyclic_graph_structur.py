"""
Algorithms for Reachability Fragility Analysis of DAGs.

Implements the key concepts from our formal theory:
- Influence computation via transitive closure
- Fragility index computation
- Hub detection and ranking
- Influence profile analysis
"""

from typing import Dict, List, Set, Tuple
from collections import defaultdict


class FinDAG:
    """A finite directed acyclic graph with reachability fragility analysis."""

    def __init__(self, vertices: List[str], edges: List[Tuple[str, str]]):
        """
        Initialize a FinDAG.

        Args:
            vertices: List of vertex labels
            edges: List of (source, target) directed edges
        """
        self.vertices: List[str] = list(vertices)
        self.edges: List[Tuple[str, str]] = list(edges)
        self.adj: Dict[str, Set[str]] = defaultdict(set)
        self.rev_adj: Dict[str, Set[str]] = defaultdict(set)
        for u, v in edges:
            self.adj[u].add(v)
            self.rev_adj[v].add(u)

        # Validate acyclicity
        if not self._is_acyclic():
            raise ValueError("Graph contains a cycle — not a valid DAG")

    def _is_acyclic(self) -> bool:
        """Check acyclicity using topological sort (Kahn's algorithm)."""
        in_deg = {v: 0 for v in self.vertices}
        for u, v in self.edges:
            in_deg[v] += 1
        queue = [v for v in self.vertices if in_deg[v] == 0]
        count = 0
        while queue:
            node = queue.pop(0)
            count += 1
            for w in self.adj[node]:
                in_deg[w] -= 1
                if in_deg[w] == 0:
                    queue.append(w)
        return count == len(self.vertices)

    def descendants(self, v: str) -> Set[str]:
        """
        Compute the set of transitive descendants of v (not including v).
        Uses BFS on the adjacency structure.

        Corresponds to FinDAG.descendants in our Lean formalization.
        """
        visited: Set[str] = set()
        stack = list(self.adj[v])
        while stack:
            w = stack.pop()
            if w not in visited:
                visited.add(w)
                stack.extend(self.adj[w] - visited)
        return visited

    def ancestors(self, v: str) -> Set[str]:
        """
        Compute the set of transitive ancestors of v (not including v).
        Uses BFS on the reverse adjacency structure.

        Corresponds to FinDAG.ancestors in our Lean formalization.
        """
        visited: Set[str] = set()
        stack = list(self.rev_adj[v])
        while stack:
            w = stack.pop()
            if w not in visited:
                visited.add(w)
                stack.extend(self.rev_adj[w] - visited)
        return visited

    def influence(self, v: str) -> int:
        """
        The influence of node v: number of transitive descendants.

        Corresponds to FinDAG.influence in our Lean formalization.
        """
        return len(self.descendants(v))

    def ancestor_count(self, v: str) -> int:
        """Number of transitive ancestors of v."""
        return len(self.ancestors(v))

    def hub_score(self, v: str) -> int:
        """
        The hub score: influence × ancestor_count.
        Measures the centrality of v as an intermediary.

        Corresponds to FinDAG.hubScore in our Lean formalization.
        """
        return self.influence(v) * self.ancestor_count(v)

    def fragility_index(self, v: str) -> int:
        """
        The fragility index: number of (u, w) pairs such that
        u can reach v AND v can reach w.

        Corresponds to FinDAG.fragilityIndex in our Lean formalization.
        Lower bounded by hub_score (our fragilityIndex_ge_product theorem).
        """
        anc = self.ancestors(v)
        desc = self.descendants(v)
        return len(anc) * len(desc)  # This IS the lower bound; exact fragility requires path analysis

    def influence_profile(self) -> List[int]:
        """
        The influence profile: sorted list of influence values.

        Corresponds to FinDAG.influenceProfile in our Lean formalization.
        """
        return sorted([self.influence(v) for v in self.vertices], reverse=True)

    def total_influence(self) -> int:
        """
        Sum of all influences = number of reachable pairs.

        Verified: totalInfluence_eq_reachPairs in Lean.
        """
        return sum(self.influence(v) for v in self.vertices)

    def reachable_pairs(self) -> int:
        """Total number of (u, v) pairs where u transitively reaches v."""
        return self.total_influence()  # By our theorem!

    def sources(self) -> List[str]:
        """
        Source nodes: nodes with no incoming edges.
        Guaranteed non-empty by source_exists theorem.
        """
        return [v for v in self.vertices if not self.rev_adj[v]]

    def hub_ranking(self) -> List[Tuple[str, int, int, int]]:
        """
        Rank all nodes by hub score.

        Returns: List of (vertex, influence, ancestor_count, hub_score)
                 sorted by hub_score descending.
        """
        ranking = []
        for v in self.vertices:
            inf = self.influence(v)
            anc = self.ancestor_count(v)
            ranking.append((v, inf, anc, inf * anc))
        ranking.sort(key=lambda x: -x[3])
        return ranking

    def in_degree_distribution(self) -> Dict[int, int]:
        """Compute the in-degree distribution P(k) = #{nodes with in-degree k}."""
        in_deg = {v: 0 for v in self.vertices}
        for u, v in self.edges:
            in_deg[v] += 1
        dist: Dict[int, int] = defaultdict(int)
        for d in in_deg.values():
            dist[d] += 1
        return dict(dist)

    def depth(self) -> int:
        """Length of the longest directed path in the DAG."""
        memo: Dict[str, int] = {}

        def _depth(v: str) -> int:
            if v in memo:
                return memo[v]
            if not self.adj[v]:
                memo[v] = 0
                return 0
            memo[v] = 1 + max(_depth(w) for w in self.adj[v])
            return memo[v]

        return max(_depth(v) for v in self.vertices) if self.vertices else 0


def build_mathlib_like_dag(n_theorems: int = 100, hub_fraction: float = 0.05) -> FinDAG:
    """
    Build a synthetic DAG that mimics mathematical dependency structure:
    - A small number of hub nodes (axioms/foundational theorems)
    - Many leaf theorems that depend on the hubs
    - Intermediate lemmas connecting hubs to leaves

    Args:
        n_theorems: Total number of theorem nodes
        hub_fraction: Fraction of nodes that are hubs
    """
    import random
    random.seed(42)

    n_hubs = max(2, int(n_theorems * hub_fraction))
    n_intermediate = int(n_theorems * 0.3)
    n_leaves = n_theorems - n_hubs - n_intermediate

    vertices = []
    edges = []

    # Layer 0: Hub theorems (axioms, foundational results)
    hubs = [f"Hub_{i}" for i in range(n_hubs)]
    vertices.extend(hubs)

    # Layer 1: Intermediate lemmas (depend on 1-3 hubs)
    intermediates = [f"Lem_{i}" for i in range(n_intermediate)]
    vertices.extend(intermediates)
    for lem in intermediates:
        n_deps = random.randint(1, min(3, n_hubs))
        for hub in random.sample(hubs, n_deps):
            edges.append((hub, lem))

    # Layer 2: Leaf theorems (depend on intermediates and sometimes hubs)
    leaves = [f"Thm_{i}" for i in range(n_leaves)]
    vertices.extend(leaves)
    for thm in leaves:
        # Depend on 1-3 intermediates
        n_int_deps = random.randint(1, min(3, n_intermediate))
        for lem in random.sample(intermediates, n_int_deps):
            edges.append((lem, thm))
        # Sometimes also depend directly on a hub
        if random.random() < 0.3:
            edges.append((random.choice(hubs), thm))

    return FinDAG(vertices, edges)


def compute_influence_concentration(dag: FinDAG) -> float:
    """
    Compute the Gini coefficient of influence distribution.
    Returns a value in [0, 1] where 1 means perfect concentration.
    """
    influences = sorted([dag.influence(v) for v in dag.vertices])
    n = len(influences)
    if n == 0 or sum(influences) == 0:
        return 0.0
    cumulative = 0.0
    total = sum(influences)
    gini_sum = 0.0
    for i, inf in enumerate(influences):
        cumulative += inf
        gini_sum += (2 * (i + 1) - n - 1) * inf
    return gini_sum / (n * total)
