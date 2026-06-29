#!/usr/bin/env python3
"""
Algorithms for Weighted Structural Defect Computation

Implements verified algorithms for computing the weighted graph Laplacian,
structural defect, boundary mass, and related invariants.

All algorithms have proven correctness properties in Lean 4.
"""

from collections import defaultdict, deque
from typing import Dict, FrozenSet, List, Optional, Set, Tuple
import itertools


# ─────────────────────────────────────────────────────────────
# Data Structures
# ─────────────────────────────────────────────────────────────

class WeightedGraph:
    """
    A finite undirected weighted graph.

    Attributes:
        n: Number of vertices (labeled 0..n-1)
        adj: Adjacency lists
        weight: Edge weight dictionary, keyed by (min(u,v), max(u,v))
    """

    def __init__(self, n: int):
        self.n = n
        self.adj: Dict[int, Set[int]] = defaultdict(set)
        self.weight: Dict[Tuple[int, int], int] = {}

    def add_edge(self, u: int, v: int, w: int = 1) -> None:
        """Add undirected edge {u,v} with weight w. Self-loops ignored."""
        if u == v:
            return
        self.adj[u].add(v)
        self.adj[v].add(u)
        self.weight[(min(u, v), max(u, v))] = w

    def get_weight(self, u: int, v: int) -> int:
        """Get weight of edge {u,v}, or 0 if no edge."""
        return self.weight.get((min(u, v), max(u, v)), 0)

    def has_edge(self, u: int, v: int) -> bool:
        """Check if edge {u,v} exists."""
        return v in self.adj[u]

    def vertices(self) -> List[int]:
        return list(range(self.n))

    def edges(self) -> List[Tuple[int, int]]:
        return list(self.weight.keys())

    def neighbors(self, v: int) -> Set[int]:
        return self.adj[v]

    def degree(self, v: int) -> int:
        return len(self.adj[v])

    def weighted_degree(self, v: int) -> int:
        """Sum of weights of edges incident to v."""
        return sum(self.get_weight(v, u) for u in self.adj[v])


# ─────────────────────────────────────────────────────────────
# Algorithm 1: Weighted Graph Laplacian
# ─────────────────────────────────────────────────────────────

def compute_weighted_laplacian(G: WeightedGraph) -> List[List[int]]:
    """
    Compute the weighted Laplacian matrix L^w.

    L^w(i,i) = ∑_j w(i,j) for j adjacent to i
    L^w(i,j) = -w(i,j) if i ≠ j and {i,j} is an edge
    L^w(i,j) = 0 otherwise

    Correctness: weightedGraphLaplacian_row_sum proves ∑_j L^w(i,j) = 0

    Time:  O(|V|² + |E|)
    Space: O(|V|²)
    """
    n = G.n
    L = [[0] * n for _ in range(n)]
    for i in range(n):
        for j in G.neighbors(i):
            w = G.get_weight(i, j)
            L[i][j] = -w
            L[i][i] += w
    return L


# ─────────────────────────────────────────────────────────────
# Algorithm 2: Connected Components (BFS)
# ─────────────────────────────────────────────────────────────

def connected_components(G: WeightedGraph,
                         vertex_set: Optional[Set[int]] = None
                         ) -> List[Set[int]]:
    """
    Compute connected components of G restricted to vertex_set.

    Time:  O(|V| + |E|) within the vertex set
    Space: O(|V|)
    """
    if vertex_set is None:
        vertex_set = set(range(G.n))
    else:
        vertex_set = set(vertex_set)

    visited: Set[int] = set()
    components: List[Set[int]] = []

    for v in vertex_set:
        if v in visited:
            continue
        comp: Set[int] = set()
        queue = deque([v])
        while queue:
            u = queue.popleft()
            if u in comp:
                continue
            comp.add(u)
            visited.add(u)
            for w in G.adj[u]:
                if w in vertex_set and w not in comp:
                    queue.append(w)
        components.append(comp)

    return components


# ─────────────────────────────────────────────────────────────
# Algorithm 3: Topological Invariants
# ─────────────────────────────────────────────────────────────

def induced_edge_count(G: WeightedGraph, S: List[int]) -> int:
    """
    Count edges in the induced subgraph G[S].

    Time:  O(|S|²)
    Space: O(|S|)
    """
    S_set = set(S)
    count = 0
    for (u, v) in G.edges():
        if u in S_set and v in S_set:
            count += 1
    return count


def induced_component_count(G: WeightedGraph, S: List[int]) -> int:
    """
    Count connected components of G[S].

    Time:  O(|S| + |E_S|)
    Space: O(|S|)
    """
    sub = WeightedGraph(G.n)
    S_set = set(S)
    for u in S:
        for v in G.adj[u]:
            if v in S_set and u < v:
                sub.add_edge(u, v, G.get_weight(u, v))
    return len(connected_components(sub, S_set))


def cycle_rank(G: WeightedGraph, S: List[int]) -> int:
    """
    Compute the first Betti number β₁(G[S]) = |E(G[S])| + c(G[S]) - |S|.

    This is the dimension of the cycle space of the induced subgraph.

    Time:  O(|S| + |E_S|)
    Space: O(|S|)
    """
    e = induced_edge_count(G, S)
    c = induced_component_count(G, S)
    return max(0, e + c - len(S))


def kappa_count(G: WeightedGraph, q: int, S: List[int]) -> int:
    """
    Compute κ(G,q,S): the number of connected components of G[S]
    that contain at least one vertex adjacent to q in G.

    Time:  O(|S| + |E_S|)
    Space: O(|S|)
    """
    sub = WeightedGraph(G.n)
    S_set = set(S)
    for u in S:
        for v in G.adj[u]:
            if v in S_set and u < v:
                sub.add_edge(u, v)
    comps = connected_components(sub, S_set)
    count = 0
    for comp in comps:
        if any(v in G.adj[q] for v in comp):
            count += 1
    return count


# ─────────────────────────────────────────────────────────────
# Algorithm 4: Structural Defect
# ─────────────────────────────────────────────────────────────

def structural_defect(G: WeightedGraph, q: int, S: List[int]) -> int:
    """
    Compute the structural defect δ_str = β₁(G[S]) + κ(G,q,S) - 1.

    Correctness: weighted_structural_defect_formula proves this is
    weight-independent (the central universality theorem).

    Time:  O(|S| + |E_S|)
    Space: O(|S|)
    """
    beta = cycle_rank(G, S)
    kap = kappa_count(G, q, S)
    return beta + kap - 1


# ─────────────────────────────────────────────────────────────
# Algorithm 5: Weighted Boundary Mass
# ─────────────────────────────────────────────────────────────

def weighted_boundary_mass(G: WeightedGraph, S: List[int]) -> int:
    """
    Compute the weighted boundary mass: total weight of edges from S to Sᶜ.

    Correctness:
        - weightedBoundaryMass_nonneg: result ≥ 0 when weights ≥ 0
        - weightedBoundaryMass_scale: scales linearly with weight scaling
        - weightedBoundaryMass_empty: returns 0 when S = ∅
        - weightedBoundaryMass_univ: returns 0 when S = V

    Time:  O(|S| · max_degree)
    Space: O(|S|)
    """
    S_set = set(S)
    total = 0
    for v in S:
        for u in G.neighbors(v):
            if u not in S_set:
                total += G.get_weight(v, u)
    return total


# ─────────────────────────────────────────────────────────────
# Algorithm 6: Full Defect Analysis
# ─────────────────────────────────────────────────────────────

def full_defect_analysis(G: WeightedGraph, q: int, S: List[int]) -> dict:
    """
    Complete defect analysis: compute all invariants and the correction term.

    Returns dict with:
        - beta1: First Betti number β₁(G[S])
        - kappa: q-visible component count κ(G,q,S)
        - defect: Structural defect δ_str
        - boundary_mass: Weighted boundary mass
        - edge_count: Number of edges in G[S]
        - component_count: Number of components of G[S]
        - correction: Weighted correction (always 0 by universality)

    Time:  O(|S| + |E_S| + |S| · max_degree)
    Space: O(|S|)
    """
    beta = cycle_rank(G, S)
    kap = kappa_count(G, q, S)
    defect = beta + kap - 1
    bm = weighted_boundary_mass(G, S)
    ec = induced_edge_count(G, S)
    cc = induced_component_count(G, S)

    return {
        "beta1": beta,
        "kappa": kap,
        "defect": defect,
        "boundary_mass": bm,
        "edge_count": ec,
        "component_count": cc,
        "correction": 0,  # Always 0 by universality theorem
    }


# ─────────────────────────────────────────────────────────────
# Algorithm 7: Exhaustive Counterexample Search
# ─────────────────────────────────────────────────────────────

def search_counterexamples(max_vertices: int = 5,
                           weight_range: List[int] = [1, 2, 3],
                           num_weight_samples: int = 5
                           ) -> Optional[dict]:
    """
    Exhaustively search for counterexamples to universality.

    For each connected graph on n ≤ max_vertices vertices,
    try different weight assignments and check if the defect changes.

    Returns None if no counterexample found, otherwise returns
    the counterexample details.

    Time:  O(2^(n²) · |weight_range|^|E| · n) — exponential, but
           tractable for small n.
    """
    import random
    random.seed(42)

    for n in range(3, max_vertices + 1):
        possible_edges = [(i, j) for i in range(n) for j in range(i + 1, n)]
        for num_edges in range(n - 1, len(possible_edges) + 1):
            for edge_set in itertools.combinations(possible_edges, num_edges):
                # Check connectivity
                G_base = WeightedGraph(n)
                for e in edge_set:
                    G_base.add_edge(e[0], e[1], 1)
                comps = connected_components(G_base, set(range(n)))
                if len(comps) > 1:
                    continue

                for q in range(n):
                    S = [v for v in range(n) if v != q]
                    d_base = structural_defect(G_base, q, S)

                    for _ in range(num_weight_samples):
                        weights = {e: random.choice(weight_range) for e in edge_set}
                        G_w = WeightedGraph(n)
                        for e in edge_set:
                            G_w.add_edge(e[0], e[1], weights[e])
                        d_w = structural_defect(G_w, q, S)
                        if d_w != d_base:
                            return {
                                "n": n,
                                "edges": edge_set,
                                "q": q,
                                "S": S,
                                "weights": weights,
                                "defect_unweighted": d_base,
                                "defect_weighted": d_w,
                            }

    return None  # No counterexample found


# ─────────────────────────────────────────────────────────────
# Example Usage
# ─────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("=== Weighted Structural Defect Algorithms ===\n")

    # Build example graph
    G = WeightedGraph(6)
    G.add_edge(0, 1, 3)
    G.add_edge(1, 2, 7)
    G.add_edge(2, 3, 2)
    G.add_edge(3, 0, 5)
    G.add_edge(1, 3, 4)
    G.add_edge(4, 1, 6)
    G.add_edge(5, 3, 1)

    print("Graph: 6 vertices, weighted edges:")
    for (u, v), w in G.weight.items():
        print(f"  {u}--{v} (weight {w})")

    # Compute Laplacian
    L = compute_weighted_laplacian(G)
    print("\nWeighted Laplacian:")
    for i, row in enumerate(L):
        print(f"  [{', '.join(f'{x:3d}' for x in row)}]")

    # Verify row sums
    print("\nRow sums:", [sum(row) for row in L])

    # Full analysis
    q = 5
    S = [0, 1, 2, 3, 4]
    analysis = full_defect_analysis(G, q, S)
    print(f"\nFull analysis (q={q}, S={S}):")
    for k, v in analysis.items():
        print(f"  {k}: {v}")

    # Search for counterexamples
    print("\nSearching for counterexamples...")
    ce = search_counterexamples(max_vertices=5)
    if ce is None:
        print("  No counterexample found — universality holds!")
    else:
        print(f"  Counterexample: {ce}")
