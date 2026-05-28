"""
algorithms.py — Overlap Class Rigidity: Algorithms for Computing
Support Overlap Graphs, Overlap Classes, and Tropical Kernel Invariants

This module implements the core computational machinery for the overlap
class theory of tropical kernel generators on finite graphs.
"""

from typing import Dict, List, Set, Tuple, Optional, FrozenSet
from collections import defaultdict
from itertools import combinations
import math


class UnionFind:
    """Disjoint set / union-find data structure for computing connected components."""
    def __init__(self, elements):
        self.parent = {x: x for x in elements}
        self.rank = {x: 0 for x in elements}

    def find(self, x):
        if self.parent[x] != x:
            self.parent[x] = self.find(self.parent[x])
        return self.parent[x]

    def union(self, x, y):
        rx, ry = self.find(x), self.find(y)
        if rx == ry:
            return
        if self.rank[rx] < self.rank[ry]:
            rx, ry = ry, rx
        self.parent[ry] = rx
        if self.rank[rx] == self.rank[ry]:
            self.rank[rx] += 1

    def components(self):
        comp = defaultdict(set)
        for x in self.parent:
            comp[self.find(x)].add(x)
        return list(comp.values())


def supports_overlap(A: FrozenSet, B: FrozenSet) -> bool:
    """Check if two support sets overlap (have nonempty intersection)."""
    return len(A & B) > 0


def cross_overlap_count(A: FrozenSet, B: FrozenSet) -> int:
    """Compute the cardinality of the intersection of two support sets."""
    return len(A & B)


def build_support_overlap_graph(
    supports: List[FrozenSet]
) -> Dict[int, Set[int]]:
    """
    Build the support overlap graph.

    Args:
        supports: List of support sets (frozensets of vertices).

    Returns:
        Adjacency dict: maps each index to the set of indices it overlaps with.

    Time complexity: O(n^2 * max_support_size) where n = len(supports).
    """
    n = len(supports)
    adj: Dict[int, Set[int]] = {i: set() for i in range(n)}
    for i, j in combinations(range(n), 2):
        if supports_overlap(supports[i], supports[j]):
            adj[i].add(j)
            adj[j].add(i)
    return adj


def compute_overlap_degree(supports: List[FrozenSet]) -> int:
    """
    Compute the overlap degree: number of edges in the support overlap graph.

    Time complexity: O(n^2 * max_support_size).
    """
    count = 0
    for i, j in combinations(range(len(supports)), 2):
        if supports_overlap(supports[i], supports[j]):
            count += 1
    return count


def compute_overlap_classes(supports: List[FrozenSet]) -> List[Set[int]]:
    """
    Compute the overlap classes: connected components of the support
    overlap graph.

    Args:
        supports: List of support sets.

    Returns:
        List of sets, each set containing the indices in one overlap class.

    Time complexity: O(n^2 * max_support_size) using union-find.
    """
    n = len(supports)
    if n == 0:
        return []
    uf = UnionFind(range(n))
    for i, j in combinations(range(n), 2):
        if supports_overlap(supports[i], supports[j]):
            uf.union(i, j)
    return uf.components()


def compute_overlap_signature(supports: List[FrozenSet]) -> List[int]:
    """
    Compute the overlap signature: sorted list of intersection
    cardinalities for all overlapping pairs.

    Returns:
        Sorted list of positive integers.
    """
    sig = []
    for i, j in combinations(range(len(supports)), 2):
        c = cross_overlap_count(supports[i], supports[j])
        if c > 0:
            sig.append(c)
    sig.sort()
    return sig


def max_overlap_degree(supports: List[FrozenSet]) -> int:
    """Compute the maximum intersection cardinality over all pairs."""
    max_deg = 0
    for i, j in combinations(range(len(supports)), 2):
        c = cross_overlap_count(supports[i], supports[j])
        max_deg = max(max_deg, c)
    return max_deg


def compute_interaction_vertices(supports: List[FrozenSet]) -> Set:
    """
    Compute the set of interaction vertices: vertices belonging to
    at least two distinct supports.
    """
    count = defaultdict(int)
    for s in supports:
        for v in s:
            count[v] += 1
    return {v for v, c in count.items() if c >= 2}


def family_union(supports: List[FrozenSet]) -> FrozenSet:
    """Compute the union of all supports."""
    result = set()
    for s in supports:
        result |= s
    return frozenset(result)


class Graph:
    """Simple undirected graph for combinatorial computations."""

    def __init__(self, n: int, edges: List[Tuple[int, int]]):
        """
        Args:
            n: Number of vertices (labeled 0..n-1).
            edges: List of (u, v) edges.
        """
        self.n = n
        self.adj: Dict[int, Set[int]] = {i: set() for i in range(n)}
        for u, v in edges:
            if u != v:
                self.adj[u].add(v)
                self.adj[v].add(u)

    def degree(self, v: int) -> int:
        return len(self.adj[v])

    def neighbors(self, v: int) -> Set[int]:
        return self.adj[v]

    def is_connected(self) -> bool:
        if self.n == 0:
            return True
        visited = set()
        stack = [0]
        while stack:
            v = stack.pop()
            if v in visited:
                continue
            visited.add(v)
            for w in self.adj[v]:
                if w not in visited:
                    stack.append(w)
        return len(visited) == self.n

    def induced_subgraph(self, S: Set[int]) -> 'Graph':
        """Return the induced subgraph on vertex set S."""
        vertices = sorted(S)
        relabel = {v: i for i, v in enumerate(vertices)}
        edges = []
        for v in vertices:
            for w in self.adj[v]:
                if w in S and v < w:
                    edges.append((relabel[v], relabel[w]))
        return Graph(len(vertices), edges)

    def connected_components(self) -> List[Set[int]]:
        visited = set()
        components = []
        for v in range(self.n):
            if v not in visited:
                comp = set()
                stack = [v]
                while stack:
                    u = stack.pop()
                    if u in visited:
                        continue
                    visited.add(u)
                    comp.add(u)
                    for w in self.adj[u]:
                        if w not in visited:
                            stack.append(w)
                components.append(comp)
        return components

    def cycle_rank(self) -> int:
        """Compute the cycle rank (first Betti number): |E| - |V| + c."""
        edge_count = sum(len(self.adj[v]) for v in range(self.n)) // 2
        num_components = len(self.connected_components())
        return edge_count - self.n + num_components

    def find_cycles_dfs(self) -> List[Set[int]]:
        """
        Find a fundamental set of cycles using DFS.
        Returns a list of vertex sets, one per independent cycle.
        """
        visited = set()
        parent = {}
        cycles = []

        def dfs(v, p):
            visited.add(v)
            parent[v] = p
            for w in self.adj[v]:
                if w == p:
                    continue
                if w in visited:
                    # Back edge found — extract cycle
                    cycle = {w}
                    u = v
                    while u != w:
                        cycle.add(u)
                        u = parent[u]
                    cycles.append(cycle)
                else:
                    dfs(w, v)

        for v in range(self.n):
            if v not in visited:
                dfs(v, -1)
        return cycles


def compute_cycle_supports(G: Graph, S: Set[int]) -> List[FrozenSet[int]]:
    """
    Compute the cycle supports in the induced subgraph G[S].

    Returns a list of frozensets, each representing the vertex support
    of a fundamental cycle.
    """
    sub = G.induced_subgraph(S)
    vertices = sorted(S)
    cycles = sub.find_cycles_dfs()
    # Map back to original vertex labels
    return [frozenset(vertices[i] for i in cycle) for cycle in cycles]


def enumerate_small_connected_graphs(n: int) -> List[Graph]:
    """
    Enumerate all non-isomorphic connected simple graphs on n vertices.
    For small n (≤ 7), this is feasible by brute force.

    Note: This does NOT check isomorphism — it generates all connected
    graphs, possibly with duplicates up to isomorphism. For conjecture
    testing, this is fine since we test all instances.
    """
    if n <= 0:
        return []
    if n == 1:
        return [Graph(1, [])]

    all_possible_edges = list(combinations(range(n), 2))
    m = len(all_possible_edges)
    results = []

    for mask in range(1, 1 << m):
        edges = [all_possible_edges[i] for i in range(m) if mask & (1 << i)]
        G = Graph(n, edges)
        if G.is_connected():
            results.append(G)

    return results


def test_overlap_conjecture(
    G: Graph, q: int, S: Set[int], verbose: bool = False
) -> Dict:
    """
    Test the overlap class conjecture for a specific (G, q, S) triple.

    The conjecture: the number of overlap classes of cycle supports in G[S]
    provides structural information about tropical kernel generators.

    Returns a dict with computed invariants.
    """
    cycle_supports = compute_cycle_supports(G, S)

    if not cycle_supports:
        return {
            'graph_vertices': G.n,
            'basepoint': q,
            'subset': S,
            'num_cycle_supports': 0,
            'overlap_degree': 0,
            'overlap_class_count': 0,
            'overlap_signature': [],
            'max_overlap_deg': 0,
            'interaction_vertices': set(),
            'is_pairwise_disjoint': True,
        }

    overlap_deg = compute_overlap_degree(cycle_supports)
    classes = compute_overlap_classes(cycle_supports)
    sig = compute_overlap_signature(cycle_supports)
    max_deg = max_overlap_degree(cycle_supports)
    interaction = compute_interaction_vertices(cycle_supports)

    result = {
        'graph_vertices': G.n,
        'basepoint': q,
        'subset': S,
        'num_cycle_supports': len(cycle_supports),
        'cycle_supports': cycle_supports,
        'overlap_degree': overlap_deg,
        'overlap_class_count': len(classes),
        'overlap_classes': classes,
        'overlap_signature': sig,
        'max_overlap_deg': max_deg,
        'interaction_vertices': interaction,
        'is_pairwise_disjoint': overlap_deg == 0,
    }

    if verbose:
        print(f"  Cycle supports: {cycle_supports}")
        print(f"  Overlap degree: {overlap_deg}")
        print(f"  Overlap classes: {len(classes)}")
        print(f"  Overlap signature: {sig}")
        print(f"  Max overlap degree: {max_deg}")
        print(f"  Interaction vertices: {interaction}")
        print(f"  Pairwise disjoint: {overlap_deg == 0}")

    return result


def batch_test_conjecture(max_n: int = 6, verbose: bool = False) -> Dict:
    """
    Batch test the overlap class conjecture across all connected graphs
    up to max_n vertices.

    Returns summary statistics.
    """
    summary = {
        'total_tests': 0,
        'disjoint_cases': 0,
        'overlapping_cases': 0,
        'max_overlap_degree_seen': 0,
        'max_overlap_classes_seen': 0,
        'examples': [],
    }

    for n in range(2, max_n + 1):
        if verbose:
            print(f"\n=== Testing n = {n} ===")
        graphs = enumerate_small_connected_graphs(n)

        for gi, G in enumerate(graphs[:50]):  # limit for efficiency
            for q in range(n):
                remaining = set(range(n)) - {q}
                # Test a few subsets
                for size in range(2, min(n, 5)):
                    from itertools import combinations as combo
                    for S_tuple in combo(sorted(remaining), size):
                        S = set(S_tuple)
                        result = test_overlap_conjecture(G, q, S, verbose=False)
                        summary['total_tests'] += 1

                        if result['is_pairwise_disjoint']:
                            summary['disjoint_cases'] += 1
                        else:
                            summary['overlapping_cases'] += 1

                        summary['max_overlap_degree_seen'] = max(
                            summary['max_overlap_degree_seen'],
                            result['overlap_degree']
                        )
                        summary['max_overlap_classes_seen'] = max(
                            summary['max_overlap_classes_seen'],
                            result['overlap_class_count']
                        )

                        if result['overlap_degree'] > 0 and len(summary['examples']) < 10:
                            summary['examples'].append(result)

    return summary


if __name__ == '__main__':
    print("=== Overlap Class Rigidity: Algorithm Tests ===\n")

    # Example 1: Disjoint supports
    print("Example 1: Disjoint supports")
    supports_disjoint = [
        frozenset({0, 1}),
        frozenset({2, 3}),
        frozenset({4, 5}),
    ]
    print(f"  Supports: {supports_disjoint}")
    print(f"  Overlap degree: {compute_overlap_degree(supports_disjoint)}")
    print(f"  Overlap classes: {compute_overlap_classes(supports_disjoint)}")
    print(f"  Interaction vertices: {compute_interaction_vertices(supports_disjoint)}")
    print()

    # Example 2: Overlapping supports
    print("Example 2: Overlapping supports")
    supports_overlap = [
        frozenset({0, 1, 2}),
        frozenset({1, 2, 3}),
        frozenset({4, 5}),
    ]
    print(f"  Supports: {supports_overlap}")
    print(f"  Overlap degree: {compute_overlap_degree(supports_overlap)}")
    print(f"  Overlap classes: {compute_overlap_classes(supports_overlap)}")
    print(f"  Overlap signature: {compute_overlap_signature(supports_overlap)}")
    print(f"  Max overlap degree: {max_overlap_degree(supports_overlap)}")
    print(f"  Interaction vertices: {compute_interaction_vertices(supports_overlap)}")
    print()

    # Example 3: K4 graph cycle supports
    print("Example 3: Complete graph K4")
    K4 = Graph(4, [(0,1),(0,2),(0,3),(1,2),(1,3),(2,3)])
    S = {0, 1, 2, 3}
    cycle_supports = compute_cycle_supports(K4, S)
    print(f"  Cycle supports: {cycle_supports}")
    print(f"  Overlap degree: {compute_overlap_degree(cycle_supports)}")
    print(f"  Overlap classes: {compute_overlap_classes(cycle_supports)}")
    print()

    # Batch test
    print("Batch test (n ≤ 5):")
    results = batch_test_conjecture(max_n=5, verbose=False)
    print(f"  Total tests: {results['total_tests']}")
    print(f"  Disjoint cases: {results['disjoint_cases']}")
    print(f"  Overlapping cases: {results['overlapping_cases']}")
    print(f"  Max overlap degree seen: {results['max_overlap_degree_seen']}")
    print(f"  Max overlap classes seen: {results['max_overlap_classes_seen']}")
