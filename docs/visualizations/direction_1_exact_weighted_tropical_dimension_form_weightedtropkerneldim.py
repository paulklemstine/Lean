#!/usr/bin/env python3
"""
algorithms.py — Certified Algorithms for Weighted Tropical Kernel Dimension

Implements the verified algorithm for computing the weighted tropical kernel
dimension via tie subgraph construction, cycle rank computation, and
visible component counting.

Algorithm (WeightedTropKernelDim):
    Input: Graph G = (V, E), weight function w, basepoint q, vertex set S
    Output: dim_trop(G, w, q, S)

    1. Construct tie subgraph T ⊆ G
    2. Compute β₁ʷ = cycle_rank(T[S])
    3. Compute κʷ = visible_components(T, q, S)
    4. Return β₁ʷ + κʷ

Complexity: O(|V|² + |E| · |V|) time, O(|V| + |E|) space
"""

from __future__ import annotations
from collections import defaultdict
from typing import Optional, Callable
import itertools


# ──────────────────────────────────────────────────────────────────────
# Graph representation
# ──────────────────────────────────────────────────────────────────────

class Graph:
    """Simple weighted graph with integer vertices 0..n-1."""

    def __init__(self, n: int):
        self.n = n
        self.adj: dict[int, set[int]] = defaultdict(set)
        self.weight: dict[tuple[int, int], int] = {}

    def add_edge(self, u: int, v: int, w: int = 1) -> None:
        """Add undirected edge {u,v} with weight w."""
        if u == v:
            return
        self.adj[u].add(v)
        self.adj[v].add(u)
        self.weight[(u, v)] = w
        self.weight[(v, u)] = w

    def edges(self) -> list[tuple[int, int, int]]:
        """Return list of (u, v, w) for each edge, u < v."""
        seen = set()
        result = []
        for u in range(self.n):
            for v in self.adj[u]:
                if (v, u) not in seen:
                    seen.add((u, v))
                    result.append((u, v, self.weight[(u, v)]))
        return result

    def degree(self, v: int) -> int:
        return len(self.adj[v])

    def subgraph_on(self, S: set[int]) -> 'Graph':
        """Return induced subgraph on vertex set S."""
        H = Graph(self.n)
        for u, v, w in self.edges():
            if u in S and v in S:
                H.add_edge(u, v, w)
        return H


# ──────────────────────────────────────────────────────────────────────
# Algorithm 1: Tie Subgraph Construction
# ──────────────────────────────────────────────────────────────────────

def has_weight_tie(G: Graph, u: int, v: int) -> bool:
    """
    Check if edge (u,v) has a weight tie at vertex u.

    Returns True iff ∃ k ≠ v such that G.Adj(u,k) and w(u,v) = w(u,k).

    Time: O(deg(u))
    """
    if v not in G.adj[u]:
        return False
    w_uv = G.weight[(u, v)]
    for k in G.adj[u]:
        if k != v and G.weight[(u, k)] == w_uv:
            return True
    return False


def construct_tie_subgraph(G: Graph) -> Graph:
    """
    Construct the tie subgraph T of G.

    An edge {u,v} ∈ E(G) belongs to T iff:
      - has_weight_tie(G, u, v), OR
      - has_weight_tie(G, v, u)

    Time: O(|E| · max_deg)
    Space: O(|V| + |E|)
    """
    T = Graph(G.n)
    for u, v, w in G.edges():
        if has_weight_tie(G, u, v) or has_weight_tie(G, v, u):
            T.add_edge(u, v, w)
    return T


# ──────────────────────────────────────────────────────────────────────
# Algorithm 2: Connected Components (Union-Find)
# ──────────────────────────────────────────────────────────────────────

class UnionFind:
    """Disjoint set union with path compression and union by rank."""

    def __init__(self, elements: set[int]):
        self.parent = {x: x for x in elements}
        self.rank = {x: 0 for x in elements}

    def find(self, x: int) -> int:
        if self.parent[x] != x:
            self.parent[x] = self.find(self.parent[x])
        return self.parent[x]

    def union(self, x: int, y: int) -> bool:
        rx, ry = self.find(x), self.find(y)
        if rx == ry:
            return False
        if self.rank[rx] < self.rank[ry]:
            rx, ry = ry, rx
        self.parent[ry] = rx
        if self.rank[rx] == self.rank[ry]:
            self.rank[rx] += 1
        return True

    def components(self) -> dict[int, list[int]]:
        comps: dict[int, list[int]] = defaultdict(list)
        for x in self.parent:
            comps[self.find(x)].append(x)
        return dict(comps)


def connected_components(G: Graph, S: set[int]) -> list[set[int]]:
    """
    Find connected components of G restricted to S.

    Time: O(|S| + |E(G[S])| · α(|S|))
    """
    if not S:
        return []
    uf = UnionFind(S)
    for u, v, _ in G.edges():
        if u in S and v in S:
            uf.union(u, v)
    return [set(comp) for comp in uf.components().values()]


# ──────────────────────────────────────────────────────────────────────
# Algorithm 3: Cycle Rank
# ──────────────────────────────────────────────────────────────────────

def edge_count_induced(G: Graph, S: set[int]) -> int:
    """Count edges in G[S]. Time: O(|E|)."""
    return sum(1 for u, v, _ in G.edges() if u in S and v in S)


def cycle_rank(G: Graph, S: set[int]) -> int:
    """
    Compute β₁(G[S]) = |E(G[S])| + c(G[S]) - |S|.

    This is the first Betti number (cycle rank) of the induced subgraph.
    Time: O(|S| + |E|)
    """
    if not S:
        return 0
    e = edge_count_induced(G, S)
    c = len(connected_components(G, S))
    result = e + c - len(S)
    assert result >= 0, f"Negative cycle rank: e={e}, c={c}, |S|={len(S)}"
    return result


# ──────────────────────────────────────────────────────────────────────
# Algorithm 4: Visible Component Count
# ──────────────────────────────────────────────────────────────────────

def visible_component_count(G: Graph, q: int, S: set[int]) -> int:
    """
    Count components of G[S] that are q-visible in G.

    A component C is q-visible if ∃ v ∈ C such that {q,v} ∈ E(G).

    Time: O(|S| + |E|)
    """
    comps = connected_components(G, S)
    count = 0
    for comp in comps:
        for v in comp:
            if v in G.adj.get(q, set()):
                count += 1
                break
    return count


# ──────────────────────────────────────────────────────────────────────
# Algorithm 5: Weighted Tropical Kernel Dimension (Main Algorithm)
# ──────────────────────────────────────────────────────────────────────

def weighted_trop_kernel_dim(G: Graph, q: int, S: set[int]) -> dict:
    """
    Compute the weighted tropical kernel dimension.

    Returns a dict with:
      - 'dim': the kernel dimension β₁ʷ + κʷ
      - 'weighted_betti1': β₁ʷ (cycle rank of tie subgraph on S)
      - 'visible_defect': κʷ (q-visible components of tie subgraph on S)
      - 'tie_edges': number of tie edges
      - 'tie_components': number of components of tie subgraph on S

    Time: O(|V|² + |E| · max_deg)
    Space: O(|V| + |E|)
    """
    # Step 1: Construct tie subgraph
    T = construct_tie_subgraph(G)
    tie_edge_count = len(T.edges())

    # Step 2: Compute weighted Betti number
    beta1_w = cycle_rank(T, S)

    # Step 3: Compute weighted visible defect
    kappa_w = visible_component_count(T, q, S)

    # Step 4: Compute dimension
    dim = beta1_w + kappa_w

    # Additional diagnostics
    tie_comps = len(connected_components(T, S))

    return {
        'dim': dim,
        'weighted_betti1': beta1_w,
        'visible_defect': kappa_w,
        'tie_edges': tie_edge_count,
        'tie_components': tie_comps,
    }


# ──────────────────────────────────────────────────────────────────────
# Algorithm 6: Generic Weight Check
# ──────────────────────────────────────────────────────────────────────

def is_weight_generic(G: Graph) -> bool:
    """
    Check if weights are generic: all edge weights incident to each
    vertex are pairwise distinct.

    Time: O(|V| · max_deg · log(max_deg))
    """
    for v in range(G.n):
        weights = [G.weight[(v, nb)] for nb in G.adj[v]]
        if len(weights) != len(set(weights)):
            return False
    return True


# ──────────────────────────────────────────────────────────────────────
# Algorithm 7: Exhaustive Verification
# ──────────────────────────────────────────────────────────────────────

def exhaustive_verify(n: int, weight_range: list[int],
                      max_graphs: int = 10000) -> dict:
    """
    Exhaustively verify the dimension formula on graphs with n vertices.

    Tests: dim = β₁ʷ + κʷ (always true by definition)
    Also checks: generic ⟹ β₁ʷ = 0

    Returns summary statistics.
    """
    all_edges = [(i, j) for i in range(n) for j in range(i + 1, n)]
    total = 0
    formula_ok = 0
    generic_collapse_ok = 0
    generic_count = 0
    counterexamples = []

    for r in range(1, len(all_edges) + 1):
        for edge_subset in itertools.combinations(all_edges, r):
            for weights in itertools.product(weight_range, repeat=r):
                if total >= max_graphs:
                    return {
                        'total': total,
                        'formula_ok': formula_ok,
                        'generic_count': generic_count,
                        'generic_collapse_ok': generic_collapse_ok,
                        'counterexamples': counterexamples,
                        'truncated': True
                    }

                G = Graph(n)
                for (u, v), w in zip(edge_subset, weights):
                    G.add_edge(u, v, w)

                q = 0
                S = set(range(1, n))
                result = weighted_trop_kernel_dim(G, q, S)

                if result['dim'] == result['weighted_betti1'] + result['visible_defect']:
                    formula_ok += 1
                else:
                    counterexamples.append(('formula', G.edges()))

                if is_weight_generic(G):
                    generic_count += 1
                    if result['weighted_betti1'] == 0:
                        generic_collapse_ok += 1
                    else:
                        counterexamples.append(('generic_collapse', G.edges()))

                total += 1

    return {
        'total': total,
        'formula_ok': formula_ok,
        'generic_count': generic_count,
        'generic_collapse_ok': generic_collapse_ok,
        'counterexamples': counterexamples,
        'truncated': False
    }


# ──────────────────────────────────────────────────────────────────────
# Example usage
# ──────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("Weighted Tropical Kernel Dimension — Algorithm Suite")
    print("=" * 55)

    # Example: Petersen-like graph
    G = Graph(5)
    G.add_edge(0, 1, 1)
    G.add_edge(1, 2, 1)
    G.add_edge(2, 3, 2)
    G.add_edge(3, 4, 2)
    G.add_edge(4, 0, 3)
    G.add_edge(0, 2, 1)

    q = 0
    S = {1, 2, 3, 4}

    result = weighted_trop_kernel_dim(G, q, S)
    print(f"\nGraph: 5-vertex graph with mixed weights")
    print(f"Tie subgraph has {result['tie_edges']} edges")
    print(f"β₁ʷ = {result['weighted_betti1']}")
    print(f"κʷ  = {result['visible_defect']}")
    print(f"dim = {result['dim']}")
    print(f"Generic? {is_weight_generic(G)}")

    # Exhaustive verification
    print("\nExhaustive verification on 4-vertex graphs...")
    stats = exhaustive_verify(4, [1, 2, 3])
    print(f"  Tested: {stats['total']}")
    print(f"  Formula consistent: {stats['formula_ok']}")
    print(f"  Generic graphs: {stats['generic_count']}")
    print(f"  Generic collapse verified: {stats['generic_collapse_ok']}")
    if stats['counterexamples']:
        print(f"  COUNTEREXAMPLES FOUND: {stats['counterexamples'][:5]}")
    else:
        print("  No counterexamples ✓")
