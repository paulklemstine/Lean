#!/usr/bin/env python3
"""
Emotional Chromatic Theory — Algorithms

Type-hinted implementations of core algorithms from emotional chromatic theory.
"""

from typing import Dict, FrozenSet, List, Optional, Set, Tuple
import math


# ---------- Graph Representation ----------

Graph = Dict[int, Set[int]]


def make_graph(n: int, edges: List[Tuple[int, int]]) -> Graph:
    """Create an adjacency-list graph from a list of edges."""
    adj: Graph = {i: set() for i in range(n)}
    for u, v in edges:
        adj[u].add(v)
        adj[v].add(u)
    return adj


# ---------- Core Algorithms ----------

def greedy_coloring(adj: Graph, n: int) -> List[int]:
    """
    Greedy graph coloring algorithm.

    Assigns the smallest available color to each vertex in order.
    Time complexity: O(n * Δ) where Δ is the max degree.

    Returns: A list of color assignments (0-indexed).
    """
    colors: List[int] = [-1] * n
    for v in range(n):
        neighbor_colors: Set[int] = {
            colors[w] for w in adj.get(v, set()) if colors[w] != -1
        }
        c = 0
        while c in neighbor_colors:
            c += 1
        colors[v] = c
    return colors


def chromatic_number_exact(adj: Graph, n: int) -> int:
    """
    Exact chromatic number via backtracking with pruning.

    For each candidate k from 1 to n, attempts to find a proper k-coloring.
    Uses constraint propagation: if a vertex's neighborhood already uses
    all k colors, backtrack immediately.

    Time complexity: O(k^n) worst case, much better with pruning.
    """
    def can_color(v: int, c: int, assignment: List[int]) -> bool:
        return all(assignment[w] != c for w in adj.get(v, set()))

    def backtrack(v: int, k: int, assignment: List[int]) -> bool:
        if v == n:
            return True
        for c in range(k):
            if can_color(v, c, assignment):
                assignment[v] = c
                if backtrack(v + 1, k, assignment):
                    return True
                assignment[v] = -1
        return False

    for k in range(1, n + 1):
        assignment = [-1] * n
        if backtrack(0, k, assignment):
            return k
    return n


def emotional_chromatic_number(adj: Graph, n: int) -> int:
    """
    Compute the emotional chromatic number χ_E(G) = max(3, χ(G)).

    Algorithm:
    1. Compute the classical chromatic number χ(G).
    2. Return max(3, χ(G)).

    The key insight is that the emotional constraint (≥ 3 colors) only
    adds to the chromatic number when χ(G) ≤ 2.
    """
    chi = chromatic_number_exact(adj, n)
    return max(3, chi)


def find_max_clique(adj: Graph, n: int) -> List[int]:
    """
    Find a maximum clique using Bron-Kerbosch algorithm.

    The clique number ω(G) provides a lower bound: χ(G) ≥ ω(G).

    Returns: The vertices of a maximum clique.
    """
    best: List[int] = []

    def bron_kerbosch(R: Set[int], P: Set[int], X: Set[int]) -> None:
        nonlocal best
        if not P and not X:
            if len(R) > len(best):
                best = list(R)
            return
        # Choose pivot to maximize pruning
        pivot = max(P | X, key=lambda v: len(adj.get(v, set()) & P))
        for v in P - adj.get(pivot, set()):
            neighbors = adj.get(v, set())
            bron_kerbosch(R | {v}, P & neighbors, X & neighbors)
            P = P - {v}
            X = X | {v}

    bron_kerbosch(set(), set(range(n)), set())
    return best


def tropical_chromatic_polynomial(
    n: int, m: int, k_values: List[int]
) -> List[float]:
    """
    Evaluate the tropical chromatic polynomial at given k values.

    trop_eval(n, m, k) = k * n - m

    In the tropical semiring (ℝ, min, +):
    - Addition is min
    - Multiplication is +

    The monotonicity theorem guarantees that for k₁ ≤ k₂:
    min(trop_eval(k₂), trop_eval(k₁)) = trop_eval(k₁)
    """
    return [float(k * n - m) for k in k_values]


def coloring_diversity(coloring: List[int]) -> int:
    """
    Compute the coloring diversity: the number of distinct colors used.

    Bounded by:
    - diversity ≤ k (number of available colors)
    - diversity ≤ |V| (number of vertices)
    """
    return len(set(coloring))


def emotional_coloring_certificate(
    adj: Graph, n: int
) -> Tuple[int, List[int], int]:
    """
    Compute a full emotional coloring certificate.

    Returns:
    - chi_e: the emotional chromatic number
    - coloring: a proper chi_e-coloring
    - diversity: the coloring diversity
    """
    chi = chromatic_number_exact(adj, n)
    chi_e = max(3, chi)

    # Find a proper chi_e-coloring
    def backtrack(v: int, k: int, assignment: List[int]) -> bool:
        if v == n:
            return True
        for c in range(k):
            if all(assignment[w] != c for w in adj.get(v, set())):
                assignment[v] = c
                if backtrack(v + 1, k, assignment):
                    return True
                assignment[v] = -1
        return False

    assignment = [-1] * n
    backtrack(0, chi_e, assignment)

    diversity = coloring_diversity(assignment)
    return chi_e, assignment, diversity


def is_bipartite(adj: Graph, n: int) -> Tuple[bool, Optional[List[int]]]:
    """
    Check if a graph is bipartite and return a 2-coloring if so.

    A graph is bipartite iff it contains no odd cycles.
    For bipartite graphs, the emotional floor (3) strictly exceeds χ(G) = 2.
    """
    color = [-1] * n
    for start in range(n):
        if color[start] != -1:
            continue
        color[start] = 0
        stack = [start]
        while stack:
            v = stack.pop()
            for w in adj.get(v, set()):
                if color[w] == -1:
                    color[w] = 1 - color[v]
                    stack.append(w)
                elif color[w] == color[v]:
                    return False, None
    return True, color


# ---------- Main ----------

if __name__ == "__main__":
    # Demonstrate on the Petersen graph
    petersen_edges = [
        (0, 1), (1, 2), (2, 3), (3, 4), (4, 0),
        (5, 7), (7, 9), (9, 6), (6, 8), (8, 5),
        (0, 5), (1, 6), (2, 7), (3, 8), (4, 9),
    ]
    G = make_graph(10, petersen_edges)

    chi_e, coloring, diversity = emotional_coloring_certificate(G, 10)
    clique = find_max_clique(G, 10)
    bip, _ = is_bipartite(G, 10)

    print(f"Petersen graph:")
    print(f"  χ_E = {chi_e}")
    print(f"  Coloring: {coloring}")
    print(f"  Diversity: {diversity}")
    print(f"  Max clique: {clique} (size {len(clique)})")
    print(f"  Bipartite: {bip}")
    print(f"  Floor binds: {chi_e > chromatic_number_exact(G, 10)}")
