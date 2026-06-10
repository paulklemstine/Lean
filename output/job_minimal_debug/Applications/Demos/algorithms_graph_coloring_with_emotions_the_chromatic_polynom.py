"""
Emotional Chromatic Theory — Core Algorithms

Implements the emotional chromatic number, chromatic polynomial computation,
and related graph coloring algorithms.
"""

from typing import List, Set, Tuple, Dict, Optional
from itertools import product
from functools import lru_cache
import math


class Graph:
    """Simple undirected graph represented by adjacency sets."""

    def __init__(self, n: int, edges: List[Tuple[int, int]]):
        self.n = n
        self.adj: Dict[int, Set[int]] = {i: set() for i in range(n)}
        for u, v in edges:
            if u != v:
                self.adj[u].add(v)
                self.adj[v].add(u)

    @staticmethod
    def complete(n: int) -> "Graph":
        """Complete graph K_n."""
        edges = [(i, j) for i in range(n) for j in range(i + 1, n)]
        return Graph(n, edges)

    @staticmethod
    def cycle(n: int) -> "Graph":
        """Cycle graph C_n."""
        edges = [(i, (i + 1) % n) for i in range(n)]
        return Graph(n, edges)

    @staticmethod
    def path(n: int) -> "Graph":
        """Path graph P_n."""
        edges = [(i, i + 1) for i in range(n - 1)]
        return Graph(n, edges)

    @staticmethod
    def complete_bipartite(a: int, b: int) -> "Graph":
        """Complete bipartite graph K_{a,b}."""
        edges = [(i, a + j) for i in range(a) for j in range(b)]
        return Graph(a + b, edges)

    def delete_edge(self, u: int, v: int) -> "Graph":
        """Return graph with edge (u,v) removed."""
        new_edges = []
        for w in range(self.n):
            for x in self.adj[w]:
                if w < x and not (w == u and x == v) and not (w == v and x == u):
                    new_edges.append((w, x))
        return Graph(self.n, new_edges)

    def contract_edge(self, u: int, v: int) -> "Graph":
        """Return graph with edge (u,v) contracted (merge v into u)."""
        mapping = {}
        idx = 0
        for i in range(self.n):
            if i == v:
                mapping[i] = mapping[u]
            else:
                mapping[i] = idx
                idx += 1
        new_edges = set()
        for w in range(self.n):
            for x in self.adj[w]:
                mw, mx = mapping[w], mapping[x]
                if mw != mx:
                    new_edges.add((min(mw, mx), max(mw, mx)))
        return Graph(idx, list(new_edges))

    def edges(self) -> List[Tuple[int, int]]:
        """Return list of edges."""
        result = []
        for u in range(self.n):
            for v in self.adj[u]:
                if u < v:
                    result.append((u, v))
        return result


def count_colorings(g: Graph, k: int) -> int:
    """
    Count the number of proper k-colorings of graph g
    using deletion-contraction recursion.

    This is the chromatic polynomial χ_G(k).
    """
    edge_list = g.edges()
    if not edge_list:
        return k ** g.n  # Independent vertices
    u, v = edge_list[0]
    g_minus = g.delete_edge(u, v)
    g_contract = g.contract_edge(u, v)
    return count_colorings(g_minus, k) - count_colorings(g_contract, k)


def chromatic_polynomial_complete(n: int, k: int) -> int:
    """
    Chromatic polynomial of K_n evaluated at k.
    χ_{K_n}(k) = k(k-1)(k-2)...(k-n+1) = k^{(n)} (falling factorial).
    """
    result = 1
    for i in range(n):
        result *= (k - i)
    return result


def chromatic_polynomial_cycle(n: int, k: int) -> int:
    """
    Chromatic polynomial of C_n evaluated at k.
    χ_{C_n}(k) = (k-1)^n + (-1)^n * (k-1).
    """
    return (k - 1) ** n + ((-1) ** n) * (k - 1)


def chromatic_number(g: Graph) -> int:
    """
    Compute the chromatic number χ(G) by testing colorability
    for k = 1, 2, 3, ... using backtracking.
    """
    for k in range(1, g.n + 1):
        if is_colorable(g, k):
            return k
    return g.n


def is_colorable(g: Graph, k: int) -> bool:
    """Check if graph g is k-colorable using backtracking."""
    coloring = [-1] * g.n

    def backtrack(v: int) -> bool:
        if v == g.n:
            return True
        for c in range(k):
            if all(coloring[u] != c for u in g.adj[v] if coloring[u] != -1):
                coloring[v] = c
                if backtrack(v + 1):
                    return True
                coloring[v] = -1
        return False

    return backtrack(0)


def emotional_chromatic_number(g: Graph) -> int:
    """
    Compute the emotional chromatic number χ_E(G) = max(3, χ(G)).
    The minimum k ≥ 3 such that G is k-colorable.
    """
    chi = chromatic_number(g)
    return max(3, chi)


def emotional_diversity_gap(g: Graph, k: int) -> int:
    """
    Compute the emotional diversity gap δ_E(G, k).
    Returns k - 3 if G is k-colorable and k ≥ 3, else 0.
    """
    if k >= 3 and is_colorable(g, k):
        return k - 3
    return 0


def find_proper_coloring(g: Graph, k: int) -> Optional[List[int]]:
    """Find a proper k-coloring of g, or None if not k-colorable."""
    coloring = [-1] * g.n

    def backtrack(v: int) -> bool:
        if v == g.n:
            return True
        for c in range(k):
            if all(coloring[u] != c for u in g.adj[v] if coloring[u] != -1):
                coloring[v] = c
                if backtrack(v + 1):
                    return True
                coloring[v] = -1
        return False

    if backtrack(0):
        return coloring[:]
    return None


# Type aliases for clarity
EMOTIONS = ["happiness", "sadness", "anger", "fear", "disgust", "surprise"]


def emotional_assignment(g: Graph) -> Optional[List[str]]:
    """
    Find an assignment of 6 basic emotions to vertices such that
    no two adjacent vertices share an emotion.
    Returns None if the graph requires more than 6 colors.
    """
    coloring = find_proper_coloring(g, 6)
    if coloring is None:
        return None
    return [EMOTIONS[c] for c in coloring]


if __name__ == "__main__":
    # Quick self-test
    print("=== Emotional Chromatic Theory ===\n")

    # Complete graphs
    for n in range(2, 8):
        g = Graph.complete(n)
        chi_e = emotional_chromatic_number(g)
        print(f"K_{n}: χ_E = {chi_e}, χ_{n}(6) = {chromatic_polynomial_complete(n, 6)}")

    print()

    # Cycle graphs
    for n in range(3, 10):
        g = Graph.cycle(n)
        chi_e = emotional_chromatic_number(g)
        chi_poly = chromatic_polynomial_cycle(n, 6)
        print(f"C_{n}: χ_E = {chi_e}, χ(6) = {chi_poly}")

    print()

    # Emotional assignment demo
    g = Graph.cycle(5)
    assignment = emotional_assignment(g)
    if assignment:
        print(f"C_5 emotional assignment: {assignment}")
