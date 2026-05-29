"""
Algorithms for Chromatic Polynomial Computation and Emotional Network Analysis

Implements deletion-contraction, greedy coloring, and emotional diversity metrics.
"""

from typing import List, Tuple, Set, Dict, Optional
from math import factorial, log2
from functools import lru_cache
import itertools


class Graph:
    """Simple undirected graph represented by adjacency sets."""

    def __init__(self, n: int, edges: List[Tuple[int, int]] = None):
        """Create a graph on n vertices (0..n-1) with given edges."""
        self.n = n
        self.adj: Dict[int, Set[int]] = {i: set() for i in range(n)}
        if edges:
            for u, v in edges:
                self.add_edge(u, v)

    def add_edge(self, u: int, v: int) -> None:
        """Add undirected edge {u, v}."""
        if u != v:
            self.adj[u].add(v)
            self.adj[v].add(u)

    def remove_edge(self, u: int, v: int) -> None:
        """Remove edge {u, v}."""
        self.adj[u].discard(v)
        self.adj[v].discard(u)

    def has_edge(self, u: int, v: int) -> bool:
        return v in self.adj[u]

    def degree(self, v: int) -> int:
        return len(self.adj[v])

    def max_degree(self) -> int:
        """Maximum degree Δ(G)."""
        return max(self.degree(v) for v in range(self.n)) if self.n > 0 else 0

    def edges(self) -> List[Tuple[int, int]]:
        """Return list of edges (u, v) with u < v."""
        result = []
        for u in range(self.n):
            for v in self.adj[u]:
                if u < v:
                    result.append((u, v))
        return result

    def contract_edge(self, u: int, v: int) -> 'Graph':
        """Contract edge {u, v}: merge v into u, return new graph.
        
        Time: O(|V| + |E|)
        """
        # Map: vertex v -> u, vertices > v shift down by 1
        mapping = {}
        for i in range(self.n):
            if i == v:
                mapping[i] = mapping.get(u, u if u < v else u - 1)
            elif i < v:
                mapping[i] = i
            else:
                mapping[i] = i - 1

        # Correct u's mapping
        if u < v:
            mapping[u] = u
        else:
            mapping[u] = u - 1
        mapping[v] = mapping[u]

        new_n = self.n - 1
        new_edges = set()
        for a in range(self.n):
            for b in self.adj[a]:
                if a < b:
                    ma, mb = mapping[a], mapping[b]
                    if ma != mb:
                        new_edges.add((min(ma, mb), max(ma, mb)))

        return Graph(new_n, list(new_edges))

    def delete_edge(self, u: int, v: int) -> 'Graph':
        """Return a copy with edge {u, v} removed.
        
        Time: O(|V| + |E|)
        """
        g = Graph(self.n, [(a, b) for a, b in self.edges() if not ({a, b} == {u, v})])
        return g

    @staticmethod
    def complete(n: int) -> 'Graph':
        """Complete graph K_n."""
        edges = [(i, j) for i in range(n) for j in range(i + 1, n)]
        return Graph(n, edges)

    @staticmethod
    def cycle(n: int) -> 'Graph':
        """Cycle graph C_n (n >= 3)."""
        edges = [(i, (i + 1) % n) for i in range(n)]
        return Graph(n, edges)

    @staticmethod
    def path(n: int) -> 'Graph':
        """Path graph P_n."""
        edges = [(i, i + 1) for i in range(n - 1)]
        return Graph(n, edges)

    @staticmethod
    def star(n: int) -> 'Graph':
        """Star graph S_n (center = 0, n-1 leaves)."""
        edges = [(0, i) for i in range(1, n)]
        return Graph(n, edges)

    @staticmethod
    def empty(n: int) -> 'Graph':
        """Empty graph on n vertices (no edges)."""
        return Graph(n, [])


def chromatic_polynomial_deletion_contraction(G: Graph, k: int) -> int:
    """Compute χ(G, k) via deletion-contraction.
    
    Algorithm: Pick any edge {u,v}.
      χ(G, k) = χ(G-e, k) - χ(G/e, k)
    where G-e deletes the edge and G/e contracts it.
    
    Base case: empty graph on n vertices → k^n.
    
    Time complexity: O(2^|E|) in worst case (exponential in edges).
    Space complexity: O(|E|) recursion depth.
    
    Args:
        G: Input graph
        k: Number of colors
    
    Returns:
        Number of proper k-colorings
    """
    edges = G.edges()
    if not edges:
        return k ** G.n

    u, v = edges[0]
    G_delete = G.delete_edge(u, v)
    G_contract = G.contract_edge(u, v)
    return (chromatic_polynomial_deletion_contraction(G_delete, k)
            - chromatic_polynomial_deletion_contraction(G_contract, k))


def greedy_coloring(G: Graph) -> List[int]:
    """Greedy graph coloring algorithm.
    
    Colors vertices in order 0, 1, ..., n-1. Each vertex gets the
    smallest color not used by any already-colored neighbor.
    
    Guarantee: Uses at most Δ(G) + 1 colors (proved in our Lean formalization).
    
    Time: O(|V| + |E|)
    Space: O(|V|)
    
    Returns:
        List of colors assigned to each vertex.
    """
    n = G.n
    coloring = [-1] * n

    for v in range(n):
        # Find colors used by neighbors
        used = set()
        for u in G.adj[v]:
            if coloring[u] >= 0:
                used.add(coloring[u])

        # Assign smallest unused color
        color = 0
        while color in used:
            color += 1
        coloring[v] = color

    return coloring


def emotional_chromatic_number(G: Graph) -> int:
    """Compute the emotional chromatic number χ_E(G).
    
    Definition: min{k ≥ 3 : χ(G, k) > 0}
    
    By our greedy coloring theorem, χ_E(G) ≤ max(Δ(G) + 1, 3).
    
    Time: O(Δ(G) * 2^|E|) worst case via deletion-contraction.
    """
    for k in range(3, G.n + 4):
        if chromatic_polynomial_deletion_contraction(G, k) > 0:
            return k
    return G.n + 3  # fallback


def emotional_diversity_index(G: Graph, k: int) -> float:
    """Compute the emotional diversity index.
    
    D(G, k) = χ(G, k) / k^|V|
    
    Measures what fraction of k-color assignments are conflict-free.
    D = 1 for empty graphs, D → 0 for dense graphs.
    """
    if k == 0:
        return 0.0
    cc = chromatic_polynomial_deletion_contraction(G, k)
    return cc / (k ** G.n)


def channel_capacity_bits(G: Graph, k: int) -> float:
    """Information-theoretic channel capacity in bits.
    
    C(G, k) = log2(χ(G, k)) / |V|  bits per vertex.
    
    Interpretation: each vertex can independently encode
    C bits of information while maintaining conflict-free emotions.
    """
    cc = chromatic_polynomial_deletion_contraction(G, k)
    if cc <= 0 or G.n == 0:
        return 0.0
    return log2(cc) / G.n


# ─── Example Usage ──────────────────────────────────────────────────────
if __name__ == "__main__":
    print("=== Chromatic Polynomial via Deletion-Contraction ===")
    print()

    # K_4 with 4 colors should give 4! = 24
    K4 = Graph.complete(4)
    print(f"χ(K_4, 4) = {chromatic_polynomial_deletion_contraction(K4, 4)}")
    print(f"Expected: {factorial(4)}")

    # K_4 with 6 colors = 6·5·4·3 = 360
    print(f"χ(K_4, 6) = {chromatic_polynomial_deletion_contraction(K4, 6)}")
    print(f"Expected: {6*5*4*3}")

    # Cycle C_5 with 3 colors = (3-1)^5 + (-1)^5*(3-1) = 32 - 2 = 30
    C5 = Graph.cycle(5)
    print(f"χ(C_5, 3) = {chromatic_polynomial_deletion_contraction(C5, 3)}")
    print(f"Expected: 30")

    print()
    print("=== Greedy Coloring ===")
    print()

    for name, g in [("K_4", K4), ("C_5", C5), ("P_5", Graph.path(5)),
                     ("Star_5", Graph.star(5))]:
        coloring = greedy_coloring(g)
        num_colors = max(coloring) + 1 if coloring else 0
        print(f"  {name}: coloring={coloring}, uses {num_colors} colors, "
              f"max_degree={g.max_degree()}, bound={g.max_degree()+1}")

    print()
    print("=== Emotional Chromatic Number ===")
    print()

    for name, g in [("K_3", Graph.complete(3)), ("K_5", Graph.complete(5)),
                     ("C_4", Graph.cycle(4)), ("C_5", Graph.cycle(5)),
                     ("P_5", Graph.path(5)), ("Star_4", Graph.star(4))]:
        ecn = emotional_chromatic_number(g)
        print(f"  χ_E({name}) = {ecn}")

    print()
    print("=== Emotional Diversity with k=6 (Ekman's emotions) ===")
    print()

    k = 6
    for name, g in [("K_3", Graph.complete(3)), ("K_6", Graph.complete(6)),
                     ("C_5", Graph.cycle(5)), ("P_5", Graph.path(5)),
                     ("E_5", Graph.empty(5))]:
        div = emotional_diversity_index(g, k)
        cap = channel_capacity_bits(g, k)
        print(f"  {name}: diversity={div:.4f}, capacity={cap:.4f} bits/vertex")
