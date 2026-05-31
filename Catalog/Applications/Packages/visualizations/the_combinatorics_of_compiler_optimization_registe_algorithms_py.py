"""
Register Allocation via Graph Coloring: Core Algorithms

This module implements the key algorithms for register allocation modeled
as graph coloring problems, including greedy coloring, chordal graph recognition,
perfect elimination ordering, and spill cost optimization.

Type-hinted implementations corresponding to the formally verified theorems
in Algebra/RegisterAllocation.lean.
"""

from __future__ import annotations
from dataclasses import dataclass, field
from typing import Optional


@dataclass
class InterferenceGraph:
    """
    An interference graph for register allocation.
    Variables are vertices (0..n-1), edges connect simultaneously-live variables.
    """
    n: int  # number of variables
    adj: list[list[bool]]  # adjacency matrix

    def __post_init__(self) -> None:
        assert len(self.adj) == self.n
        for row in self.adj:
            assert len(row) == self.n
        for i in range(self.n):
            assert not self.adj[i][i], "No self-loops"
            for j in range(self.n):
                assert self.adj[i][j] == self.adj[j][i], "Symmetric"

    @staticmethod
    def from_edges(n: int, edges: list[tuple[int, int]]) -> InterferenceGraph:
        """Construct from edge list."""
        adj = [[False] * n for _ in range(n)]
        for u, v in edges:
            adj[u][v] = True
            adj[v][u] = True
        return InterferenceGraph(n=n, adj=adj)

    def neighbors(self, v: int) -> list[int]:
        """Return sorted list of neighbors of vertex v."""
        return [u for u in range(self.n) if self.adj[v][u]]

    def degree(self, v: int) -> int:
        """Degree of vertex v."""
        return sum(1 for u in range(self.n) if self.adj[v][u])

    def max_degree(self) -> int:
        """Maximum degree Δ(G)."""
        if self.n == 0:
            return 0
        return max(self.degree(v) for v in range(self.n))

    def is_clique(self, vertices: list[int]) -> bool:
        """Check if a set of vertices forms a clique."""
        for i, u in enumerate(vertices):
            for v in vertices[i + 1:]:
                if not self.adj[u][v]:
                    return False
        return True

    def clique_number(self) -> int:
        """Compute the clique number ω(G) via brute force (exponential)."""
        from itertools import combinations
        omega = 0
        for k in range(1, self.n + 1):
            found = False
            for subset in combinations(range(self.n), k):
                if self.is_clique(list(subset)):
                    omega = k
                    found = True
                    break
            if not found:
                break
        return omega

    def is_simplicial(self, v: int) -> bool:
        """Check if vertex v is simplicial (neighbors form a clique)."""
        nbrs = self.neighbors(v)
        return self.is_clique(nbrs)


@dataclass
class ColoringResult:
    """Result of a graph coloring algorithm."""
    colors: list[int]  # color assignment for each vertex
    num_colors: int  # number of distinct colors used
    is_valid: bool  # whether the coloring is proper


def greedy_coloring(G: InterferenceGraph, order: Optional[list[int]] = None) -> ColoringResult:
    """
    Greedy graph coloring algorithm.

    Processes vertices in the given order (default: 0, 1, ..., n-1).
    Assigns each vertex the smallest color not used by its already-colored neighbors.

    Theorem (verified in Lean): This uses at most Δ(G) + 1 colors.

    Args:
        G: The interference graph
        order: Vertex processing order (default: natural order)

    Returns:
        ColoringResult with the proper coloring
    """
    if order is None:
        order = list(range(G.n))

    colors = [-1] * G.n

    for v in order:
        # Colors used by already-colored neighbors
        used = set()
        for u in G.neighbors(v):
            if colors[u] >= 0:
                used.add(colors[u])

        # Assign smallest available color
        c = 0
        while c in used:
            c += 1
        colors[v] = c

    num_colors = max(colors) + 1 if G.n > 0 else 0
    is_valid = all(
        colors[u] != colors[v]
        for u in range(G.n)
        for v in G.neighbors(u)
    )

    return ColoringResult(colors=colors, num_colors=num_colors, is_valid=is_valid)


def find_perfect_elimination_ordering(G: InterferenceGraph) -> Optional[list[int]]:
    """
    Find a perfect elimination ordering (PEO) if the graph is chordal.

    Uses the Maximum Cardinality Search (MCS) algorithm:
    1. Start with an arbitrary vertex
    2. Always pick the unvisited vertex with the most visited neighbors
    3. The reverse of this order is a PEO (if the graph is chordal)

    Returns:
        PEO as a list of vertices, or None if the graph is not chordal.
    """
    if G.n == 0:
        return []

    order: list[int] = []
    visited = [False] * G.n
    weights = [0] * G.n

    for _ in range(G.n):
        # Pick unvisited vertex with maximum weight
        best = -1
        best_weight = -1
        for v in range(G.n):
            if not visited[v] and weights[v] > best_weight:
                best = v
                best_weight = weights[v]
        if best == -1:
            break

        order.append(best)
        visited[best] = True

        # Update weights of unvisited neighbors
        for u in G.neighbors(best):
            if not visited[u]:
                weights[u] += 1

    # Reverse to get PEO
    peo = list(reversed(order))

    # Verify it's actually a PEO
    if _verify_peo(G, peo):
        return peo
    return None


def _verify_peo(G: InterferenceGraph, order: list[int]) -> bool:
    """Verify that an ordering is a perfect elimination ordering."""
    pos = {v: i for i, v in enumerate(order)}

    for idx, v in enumerate(order):
        # Later neighbors of v (those appearing after v in the ordering)
        later_nbrs = [u for u in G.neighbors(v) if pos[u] > idx]

        # Check that later neighbors form a clique
        for i, u in enumerate(later_nbrs):
            for w in later_nbrs[i + 1:]:
                if not G.adj[u][w]:
                    return False
    return True


def optimal_coloring_chordal(G: InterferenceGraph) -> Optional[ColoringResult]:
    """
    Optimal coloring for chordal graphs using PEO.

    Theorem (verified in Lean): For chordal graphs, greedy coloring along
    a PEO uses exactly ω(G) colors, achieving χ(G) = ω(G).

    Returns:
        Optimal ColoringResult, or None if graph is not chordal.
    """
    peo = find_perfect_elimination_ordering(G)
    if peo is None:
        return None
    return greedy_coloring(G, order=peo)


@dataclass
class SpillResult:
    """Result of a spill analysis."""
    spilled: list[int]  # indices of spilled variables
    remaining_colors: list[int]  # coloring of non-spilled variables
    spill_cost: int  # number of variables spilled


def degree_based_spilling(G: InterferenceGraph, k: int) -> SpillResult:
    """
    Degree-based spilling heuristic for register allocation.

    When k registers are insufficient, iteratively remove the vertex
    with maximum degree until the remaining graph is k-colorable.

    Theorem (verified in Lean): If the graph has a clique of size m > k,
    at least m - k vertices must be spilled.

    Args:
        G: The interference graph
        k: Number of available registers

    Returns:
        SpillResult with spilled vertices and remaining coloring
    """
    spilled: list[int] = []
    active = list(range(G.n))

    while True:
        # Build subgraph on active vertices
        sub_n = len(active)
        if sub_n == 0:
            return SpillResult(spilled=spilled, remaining_colors=[], spill_cost=len(spilled))

        idx_map = {v: i for i, v in enumerate(active)}
        sub_adj = [[False] * sub_n for _ in range(sub_n)]
        for i, u in enumerate(active):
            for j, v in enumerate(active):
                if i != j and G.adj[u][v]:
                    sub_adj[i][j] = True

        sub_G = InterferenceGraph(n=sub_n, adj=sub_adj)

        # Try coloring with k colors
        result = greedy_coloring(sub_G)
        if result.num_colors <= k:
            # Map colors back to original vertices
            colors = [-1] * G.n
            for i, v in enumerate(active):
                colors[v] = result.colors[i]
            return SpillResult(
                spilled=spilled,
                remaining_colors=colors,
                spill_cost=len(spilled)
            )

        # Spill vertex with maximum degree in subgraph
        max_deg_vertex = max(range(sub_n), key=lambda v: sub_G.degree(v))
        original_vertex = active[max_deg_vertex]
        spilled.append(original_vertex)
        active.remove(original_vertex)


def chromatic_number_exact(G: InterferenceGraph) -> int:
    """
    Compute exact chromatic number by trying all possible numbers of colors.

    This is exponential in general but works for small graphs.
    """
    for k in range(G.n + 1):
        if _is_k_colorable(G, k):
            return k
    return G.n  # fallback


def _is_k_colorable(G: InterferenceGraph, k: int) -> bool:
    """Check if G is k-colorable via backtracking."""
    if k == 0:
        return G.n == 0

    colors = [-1] * G.n

    def backtrack(v: int) -> bool:
        if v == G.n:
            return True
        for c in range(k):
            if all(colors[u] != c for u in G.neighbors(v) if colors[u] >= 0):
                colors[v] = c
                if backtrack(v + 1):
                    return True
                colors[v] = -1
        return False

    return backtrack(0)


def verify_ssa_conjecture(G: InterferenceGraph) -> dict:
    """
    Verify the SSA chromatic number conjecture for a given graph.

    Conjecture: For chordal (SSA) interference graphs,
    χ(G) = ω(G) = max clique size.

    Returns dict with chi, omega, max_degree, is_chordal, conjecture_holds.
    """
    chi = chromatic_number_exact(G)
    omega = G.clique_number()
    delta = G.max_degree()
    peo = find_perfect_elimination_ordering(G)
    is_chordal = peo is not None

    return {
        "n": G.n,
        "chi": chi,
        "omega": omega,
        "delta": delta,
        "is_chordal": is_chordal,
        "conjecture_holds": chi == omega if is_chordal else None,
        "brooks_bound": delta + 1,
        "brooks_satisfied": chi <= delta + 1,
    }
