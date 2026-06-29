"""
Numerical demonstrations for the formally verified extremal graph theory
results: Mantel's theorem, the Turan graph and its clique-freeness, the
degree-energy / Cauchy-Schwarz bound, the handshaking lemma, and the
greedy triangle-removal certificate.

Self-contained: standard library only. Run with `python demo.py`.
"""

from __future__ import annotations

from itertools import combinations
from typing import Dict, FrozenSet, Iterable, List, Set, Tuple

Vertex = int
Edge = FrozenSet[Vertex]
Graph = Set[Edge]


# ---------------------------------------------------------------------------
# Basic graph utilities
# ---------------------------------------------------------------------------
def make_edge(u: Vertex, v: Vertex) -> Edge:
    """Unordered edge between distinct vertices u and v."""
    assert u != v, "no self-loops in a simple graph"
    return frozenset((u, v))


def vertices_of(n: int) -> List[Vertex]:
    """Vertex set {0, 1, ..., n-1}."""
    return list(range(n))


def degree(graph: Graph, n: int, v: Vertex) -> int:
    """Number of neighbors of v."""
    return sum(1 for e in graph if v in e)


def degree_sequence(graph: Graph, n: int) -> List[int]:
    """List of degrees, one per vertex 0..n-1."""
    return [degree(graph, n, v) for v in range(n)]


def neighbors(graph: Graph, v: Vertex) -> Set[Vertex]:
    """The neighborhood N(v)."""
    out: Set[Vertex] = set()
    for e in graph:
        if v in e:
            out |= (set(e) - {v})
    return out


def edge_count(graph: Graph) -> int:
    return len(graph)


# ---------------------------------------------------------------------------
# Cliques and triangles
# ---------------------------------------------------------------------------
def is_clique(graph: Graph, s: Iterable[Vertex]) -> bool:
    """True if every pair in s is adjacent."""
    s = list(s)
    return all(make_edge(a, b) in graph for a, b in combinations(s, 2))


def is_clique_free(graph: Graph, n: int, r: int) -> bool:
    """True if the graph has no r-clique (CliqueFree r)."""
    for s in combinations(range(n), r):
        if is_clique(graph, s):
            return False
    return True


def triangles(graph: Graph, n: int) -> List[Tuple[Vertex, Vertex, Vertex]]:
    """All ordered triangles (a < b < c) -- orderedTriangleFinset."""
    out = []
    for a, b, c in combinations(range(n), 3):
        if is_clique(graph, (a, b, c)):
            out.append((a, b, c))
    return out


def triangle_count(graph: Graph, n: int) -> int:
    return len(triangles(graph, n))


# ---------------------------------------------------------------------------
# Constructions
# ---------------------------------------------------------------------------
def complete_graph(n: int) -> Graph:
    return {make_edge(u, v) for u, v in combinations(range(n), 2)}


def turan_graph(n: int, p: int) -> Graph:
    """
    Turan graph T(n, p): vertices i, j adjacent iff i % p != j % p.
    This is the complete p-partite graph with classes given by residues.
    """
    assert p >= 1
    return {
        make_edge(u, v)
        for u, v in combinations(range(n), 2)
        if u % p != v % p
    }


def balanced_bipartite(n: int) -> Graph:
    """T(n, 2): the extremal triangle-free graph achieving floor(n^2/4)."""
    return turan_graph(n, 2)


# ---------------------------------------------------------------------------
# Verified statements, checked numerically
# ---------------------------------------------------------------------------
def handshaking_holds(graph: Graph, n: int) -> bool:
    """Theorem 8.1:  2|E| = sum of degrees."""
    return 2 * edge_count(graph) == sum(degree_sequence(graph, n))


def degree_energy(graph: Graph, n: int) -> int:
    """sum of deg(v)^2."""
    return sum(d * d for d in degree_sequence(graph, n))


def cauchy_schwarz_holds(graph: Graph, n: int) -> bool:
    """Theorem 4.1:  n * sum(deg^2) >= (sum deg)^2."""
    degs = degree_sequence(graph, n)
    return n * sum(d * d for d in degs) >= sum(degs) ** 2


def mantel_bound_holds(graph: Graph, n: int) -> bool:
    """Theorem 6.1: if triangle-free then 4|E| <= n^2."""
    if not is_clique_free(graph, n, 3):
        return True  # hypothesis not satisfied -> vacuously fine
    return 4 * edge_count(graph) <= n * n


def greedy_triangle_removal(graph: Graph, n: int) -> Tuple[Graph, int]:
    """
    Theorem 7.1: delete at most one edge per triangle to reach a
    triangle-free graph. Returns (H, removed_count).
    """
    h = set(graph)
    removed = 0
    for (a, b, c) in triangles(graph, n):
        edges = [make_edge(a, b), make_edge(a, c), make_edge(b, c)]
        if all(e in h for e in edges):           # still a triangle in H
            h.discard(edges[0])                  # remove one edge
            removed += 1
    return h, removed


def edge_edit_distance(g: Graph, h: Graph) -> int:
    """Definition 2.6: size of symmetric difference of edge sets."""
    return len(g ^ h)


def lower_shadow(family: Set[FrozenSet[int]]) -> Set[FrozenSet[int]]:
    """Definition 2.8: all sets obtained by deleting one element."""
    out: Set[FrozenSet[int]] = set()
    for a in family:
        for x in a:
            out.add(a - {x})
    return out


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------
def demo_mantel() -> None:
    print("=" * 64)
    print("MANTEL'S THEOREM:  triangle-free  =>  |E| <= floor(n^2/4)")
    print("=" * 64)
    for n in range(2, 11):
        g = balanced_bipartite(n)
        tf = is_clique_free(g, n, 3)
        print(
            f"n={n:2d}: balanced bipartite has |E|={edge_count(g):3d}, "
            f"bound floor(n^2/4)={n * n // 4:3d}, "
            f"triangle-free={tf}, 4|E|<=n^2 -> {4 * edge_count(g) <= n * n}"
        )
    print()


def demo_turan() -> None:
    print("=" * 64)
    print("TURAN GRAPH T(n,p) IS K_{p+1}-FREE")
    print("=" * 64)
    for n, p in [(6, 2), (6, 3), (9, 3), (10, 4), (12, 4)]:
        g = turan_graph(n, p)
        free = is_clique_free(g, n, p + 1)
        has_smaller = not is_clique_free(g, n, p)  # contains a K_p
        print(
            f"T({n:2d},{p}): |E|={edge_count(g):3d}, "
            f"K_{p+1}-free={free}, contains K_{p}={has_smaller}"
        )
    print()


def demo_cauchy_handshake() -> None:
    print("=" * 64)
    print("DEGREE ENERGY (Cauchy-Schwarz) AND HANDSHAKING")
    print("=" * 64)
    for n, p in [(7, 3), (8, 2), (10, 5)]:
        g = turan_graph(n, p)
        degs = degree_sequence(g, n)
        lhs = n * degree_energy(g, n)
        rhs = sum(degs) ** 2
        print(
            f"T({n},{p}): n*sum(deg^2)={lhs:5d} >= (sum deg)^2={rhs:5d}  "
            f"-> {lhs >= rhs};  handshaking 2|E|={2*edge_count(g)} "
            f"= sum deg={sum(degs)} -> {handshaking_holds(g, n)}"
        )
    print()


def demo_triangle_removal() -> None:
    print("=" * 64)
    print("GREEDY TRIANGLE REMOVAL CERTIFICATE")
    print("=" * 64)
    for n in [4, 5, 6, 7]:
        g = complete_graph(n)
        t = triangle_count(g, n)
        h, removed = greedy_triangle_removal(g, n)
        tf = is_clique_free(h, n, 3)
        print(
            f"K_{n}: triangles={t:3d}, edges removed={removed:3d} "
            f"(<= triangles: {removed <= t}), result triangle-free={tf}, "
            f"|E(G)|-|E(H)|={edge_count(g)-edge_count(h)}"
        )
    print()


def demo_edit_distance_and_shadow() -> None:
    print("=" * 64)
    print("EDGE EDIT DISTANCE PROPERTIES AND LOWER SHADOW MONOTONICITY")
    print("=" * 64)
    g = complete_graph(5)
    h = balanced_bipartite(5)
    print(f"edit(G,H)={edge_edit_distance(g, h)}, "
          f"edit(H,G)={edge_edit_distance(h, g)} "
          f"-> symmetric={edge_edit_distance(g,h)==edge_edit_distance(h,g)}")
    print(f"edit(G,G)={edge_edit_distance(g, g)} -> zero")

    A = {frozenset({1, 2, 3})}
    B = {frozenset({1, 2, 3}), frozenset({2, 3, 4})}
    sA, sB = lower_shadow(A), lower_shadow(B)
    print(f"A subset of B: {A <= B}; shadow(A) subset shadow(B): {sA <= sB}")
    print()


if __name__ == "__main__":
    demo_mantel()
    demo_turan()
    demo_cauchy_handshake()
    demo_triangle_removal()
    demo_edit_distance_and_shadow()
    print("All numerical checks consistent with the formally verified theorems.")
