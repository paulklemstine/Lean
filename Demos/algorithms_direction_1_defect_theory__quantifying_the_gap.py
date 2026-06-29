#!/usr/bin/env python3
"""
Algorithms for Tropical Bridge Defect Theory

Implements the core algorithms for computing graph-theoretic invariants
in the defect decomposition δ(G,q,S) = β₁(G[S]) + κ(G,q,S) - 1.

Algorithms:
1. Induced Cycle Rank (First Betti Number)
2. Root Component Count
3. Structural Defect
4. Exhaustive Defect Verification
5. Connected Graph Enumeration
"""

from itertools import combinations
from collections import defaultdict
from typing import Set, List, Tuple, Optional


class Graph:
    """
    Simple undirected graph with integer vertices.

    Time complexity:
        - add_edge: O(1)
        - neighbors: O(1)
        - edges: O(|V| + |E|)

    Space complexity: O(|V| + |E|)
    """

    def __init__(self, n: int, edges: Optional[List[Tuple[int, int]]] = None):
        """
        Initialize graph on n vertices {0, ..., n-1}.

        Args:
            n: Number of vertices
            edges: Optional list of (u, v) edge pairs
        """
        self.n = n
        self.adj: dict[int, set[int]] = defaultdict(set)
        if edges:
            for u, v in edges:
                self.add_edge(u, v)

    def add_edge(self, u: int, v: int) -> None:
        """Add undirected edge {u, v}. Self-loops are ignored."""
        if u != v:
            self.adj[u].add(v)
            self.adj[v].add(u)

    def vertices(self) -> Set[int]:
        return set(range(self.n))

    def edges(self) -> List[Tuple[int, int]]:
        """Return sorted list of edges as (u, v) with u < v."""
        seen = set()
        result = []
        for u in range(self.n):
            for v in self.adj[u]:
                e = (min(u, v), max(u, v))
                if e not in seen:
                    seen.add(e)
                    result.append(e)
        return sorted(result)

    def degree(self, v: int) -> int:
        return len(self.adj[v])


def connected_components(adj: dict, vertex_set: Set[int]) -> List[Set[int]]:
    """
    Compute connected components of the subgraph induced on vertex_set.

    Algorithm: BFS/DFS from each unvisited vertex.

    Time: O(|V| + |E|) where V = vertex_set, E = induced edges
    Space: O(|V|)

    Args:
        adj: Adjacency dict of the full graph
        vertex_set: Vertices to consider

    Returns:
        List of sets, each a connected component
    """
    visited = set()
    components = []
    for v in vertex_set:
        if v not in visited:
            comp = set()
            stack = [v]
            while stack:
                u = stack.pop()
                if u in comp:
                    continue
                comp.add(u)
                visited.add(u)
                for w in adj.get(u, set()):
                    if w in vertex_set and w not in comp:
                        stack.append(w)
            components.append(comp)
    return components


def induced_edge_count(G: Graph, S: Set[int]) -> int:
    """
    Count edges in the induced subgraph G[S].

    Algorithm: Check each vertex pair in S.

    Time: O(|S| · max_degree)
    Space: O(1)

    Args:
        G: Input graph
        S: Vertex subset

    Returns:
        Number of edges with both endpoints in S
    """
    count = 0
    for u in S:
        for v in G.adj[u]:
            if v in S and u < v:
                count += 1
    return count


def induced_component_count(G: Graph, S: Set[int]) -> int:
    """
    Count connected components of G[S].

    Time: O(|S| + |E(G[S])|)
    Space: O(|S|)
    """
    if not S:
        return 0
    return len(connected_components(G.adj, S))


def induced_cycle_rank(G: Graph, S: Set[int]) -> int:
    """
    Compute the first Betti number β₁(G[S]) = |E(G[S])| + c(G[S]) - |S|.

    This is the dimension of the cycle space of G[S]. It counts the
    number of independent cycles in the induced subgraph.

    For a forest (acyclic graph), β₁ = 0.
    For a single cycle on k vertices, β₁ = 1.
    For a complete graph on k vertices, β₁ = k(k-1)/2 - k + 1.

    Time: O(|S| + |E(G[S])|)
    Space: O(|S|)

    Args:
        G: Input graph
        S: Vertex subset

    Returns:
        β₁(G[S]) ≥ 0
    """
    e = induced_edge_count(G, S)
    c = induced_component_count(G, S)
    return e + c - len(S)


def root_component_count(G: Graph, q: int, S: Set[int]) -> int:
    """
    Count components of G - {q} that intersect S.

    This measures how S is distributed across the root-separated
    pieces of the graph.

    Algorithm:
    1. Compute connected components of G restricted to V \ {q}
    2. Count how many components contain at least one vertex of S

    Time: O(|V| + |E|)
    Space: O(|V|)

    Args:
        G: Input graph
        q: Root vertex
        S: Vertex subset (should not contain q)

    Returns:
        κ(G,q,S) ≥ 0
    """
    if not S:
        return 0
    remaining = G.vertices() - {q}
    comps = connected_components(G.adj, remaining)
    return sum(1 for comp in comps if comp & S)


def structural_defect(G: Graph, q: int, S: Set[int]) -> int:
    """
    Compute the structural defect δ(G,q,S) = β₁(G[S]) + κ(G,q,S) - 1.

    This is the predicted value of the tropical bridge defect:
    the gap between tropical Laplacian rank and Baker–Norine divisor rank.

    Properties (proved in Lean):
    - δ ≥ 0 for nonempty S (Theorem 1)
    - δ = 0 iff β₁ = 0 and κ = 1 (Theorem 2)
    - Acyclic + single-component implies δ = 0 (Theorem 3)

    Time: O(|V| + |E|)
    Space: O(|V|)

    Args:
        G: Input graph
        q: Root vertex
        S: Vertex subset (nonempty, not containing q)

    Returns:
        δ(G,q,S) ≥ 0
    """
    return induced_cycle_rank(G, S) + root_component_count(G, q, S) - 1


def enumerate_connected_graphs(n: int):
    """
    Enumerate all connected simple graphs on n labeled vertices.

    Algorithm: Brute-force over all possible edge sets, filtering
    for connectivity. For n ≤ 7, this is feasible.

    Complexity:
        Time: O(2^{n(n-1)/2} · n) — exponential in vertex count
        Space: O(n²) per graph

    Args:
        n: Number of vertices

    Yields:
        Graph objects for each connected graph on n vertices
    """
    all_edges = list(combinations(range(n), 2))
    for num_edges in range(n - 1, len(all_edges) + 1):
        for edge_set in combinations(all_edges, num_edges):
            G = Graph(n, edge_set)
            if len(connected_components(G.adj, G.vertices())) == 1:
                yield G


def verify_defect_theorems(max_n: int = 6) -> dict:
    """
    Exhaustively verify defect theory theorems on all small graphs.

    Tests:
    1. Nonnegativity: δ ≥ 0
    2. Zero-defect rigidity: δ = 0 ↔ (β₁ = 0 ∧ κ = 1)
    3. Tree-component exactness: (β₁ = 0 ∧ κ = 1) → δ = 0

    Args:
        max_n: Maximum number of vertices (default 6)

    Returns:
        Dictionary with test results and statistics
    """
    results = {
        'total_tests': 0,
        'nonneg_passed': 0,
        'rigidity_passed': 0,
        'exactness_passed': 0,
        'max_defect': 0,
        'defect_distribution': defaultdict(int),
    }

    for n in range(2, max_n + 1):
        for G in enumerate_connected_graphs(n):
            for q in range(n):
                for k in range(1, n):
                    remaining = [v for v in range(n) if v != q]
                    for S_tuple in combinations(remaining, k):
                        S = set(S_tuple)
                        delta = structural_defect(G, q, S)
                        beta1 = induced_cycle_rank(G, S)
                        kappa = root_component_count(G, q, S)

                        results['total_tests'] += 1
                        results['defect_distribution'][delta] += 1
                        results['max_defect'] = max(results['max_defect'], delta)

                        # Theorem 1
                        assert delta >= 0
                        results['nonneg_passed'] += 1

                        # Theorem 2
                        assert (delta == 0) == (beta1 == 0 and kappa == 1)
                        results['rigidity_passed'] += 1

                        # Theorem 3
                        if beta1 == 0 and kappa == 1:
                            assert delta == 0
                            results['exactness_passed'] += 1

    return results


def compute_defect_table(G: Graph) -> str:
    """
    Compute a table of defect values for all (q, S) pairs in G.

    Args:
        G: Connected graph

    Returns:
        Formatted string table
    """
    lines = []
    lines.append(f"Graph: {G.n} vertices, edges = {G.edges()}")
    lines.append(f"{'q':>3} {'S':>15} {'β₁':>4} {'κ':>4} {'δ':>4}")
    lines.append("-" * 35)

    for q in range(G.n):
        for k in range(1, G.n):
            remaining = [v for v in range(G.n) if v != q]
            for S_tuple in combinations(remaining, k):
                S = set(S_tuple)
                beta1 = induced_cycle_rank(G, S)
                kappa = root_component_count(G, q, S)
                delta = structural_defect(G, q, S)
                S_str = '{' + ','.join(map(str, sorted(S))) + '}'
                lines.append(f"{q:>3} {S_str:>15} {beta1:>4} {kappa:>4} {delta:>4}")

    return '\n'.join(lines)


if __name__ == "__main__":
    # Quick demonstration
    print("Defect Theory Algorithms — Quick Test")
    print()

    # Example: Petersen-like structure
    G = Graph(5, [(0, 1), (1, 2), (2, 3), (3, 4), (4, 0), (0, 2)])
    print(compute_defect_table(G))
    print()

    # Verification
    print("Running exhaustive verification (n ≤ 5)...")
    results = verify_defect_theorems(max_n=5)
    print(f"  Total tests: {results['total_tests']}")
    print(f"  All passed: ✓")
    print(f"  Max defect seen: {results['max_defect']}")
    print(f"  Defect distribution: {dict(sorted(results['defect_distribution'].items()))}")
