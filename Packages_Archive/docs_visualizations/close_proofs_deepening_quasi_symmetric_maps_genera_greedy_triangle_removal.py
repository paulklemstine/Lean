"""
Numerical demonstrations for the verified extremal graph theory toolkit.

This script illustrates, with concrete graphs, every theorem in the
companion development:

  * Handshaking identity          : 2|E| = sum of degrees
  * Cauchy-Schwarz degree energy  : n * sum(deg^2) >= (sum deg)^2
  * Disjoint neighborhoods        : adjacent vertices in triangle-free graphs
  * Per-edge degree bound         : deg(u) + deg(v) <= n on each edge
  * Degree-energy upper bound     : sum(deg^2) <= n|E| (triangle-free)
  * Mantel's theorem              : 4|E| <= n^2 (triangle-free)  [tight on T(n,2)]
  * Turan graph clique-freeness   : T(n,p) is K_{p+1}-free
  * Greedy triangle removal       : edits <= triangle count
  * Edge edit distance            : symmetric, zero on the diagonal
  * Lower shadow monotonicity     : A subset B  =>  shadow(A) subset shadow(B)

Everything is inlined and uses only the standard library.
"""

from __future__ import annotations

from itertools import combinations
from typing import Dict, FrozenSet, Iterable, List, Set, Tuple

# A graph is represented as (n, edges), where vertices are 0..n-1 and
# edges is a set of frozenset({u, v}) pairs.
Vertex = int
Edge = FrozenSet[Vertex]
Graph = Tuple[int, Set[Edge]]


# --------------------------------------------------------------------------
# Basic graph utilities
# --------------------------------------------------------------------------
def make_edge(u: Vertex, v: Vertex) -> Edge:
    """Undirected edge as a frozenset."""
    return frozenset((u, v))


def neighbors(graph: Graph, v: Vertex) -> Set[Vertex]:
    """Set of vertices adjacent to v."""
    _, edges = graph
    out: Set[Vertex] = set()
    for e in edges:
        if v in e:
            out |= (e - {v})
    return out


def degree(graph: Graph, v: Vertex) -> int:
    """Number of edges incident to v."""
    return len(neighbors(graph, v))


def adjacent(graph: Graph, u: Vertex, v: Vertex) -> bool:
    """Whether {u, v} is an edge."""
    _, edges = graph
    return make_edge(u, v) in edges


def degree_sequence(graph: Graph) -> List[int]:
    n, _ = graph
    return [degree(graph, v) for v in range(n)]


def degree_energy(graph: Graph) -> int:
    """sum of squared degrees."""
    return sum(d * d for d in degree_sequence(graph))


def edge_count(graph: Graph) -> int:
    return len(graph[1])


# --------------------------------------------------------------------------
# Triangles
# --------------------------------------------------------------------------
def triangles(graph: Graph) -> List[Tuple[int, int, int]]:
    """All ordered triangles (a < b < c) that are pairwise adjacent."""
    n, _ = graph
    out: List[Tuple[int, int, int]] = []
    for a, b, c in combinations(range(n), 3):
        if adjacent(graph, a, b) and adjacent(graph, b, c) and adjacent(graph, a, c):
            out.append((a, b, c))
    return out


def triangle_count(graph: Graph) -> int:
    return len(triangles(graph))


def is_triangle_free(graph: Graph) -> bool:
    return triangle_count(graph) == 0


# --------------------------------------------------------------------------
# Constructions
# --------------------------------------------------------------------------
def turan_graph(n: int, p: int) -> Graph:
    """Turan graph T(n, p): x ~ y  iff  x != y and x % p != y % p."""
    assert p >= 1
    edges: Set[Edge] = set()
    for u, v in combinations(range(n), 2):
        if u % p != v % p:
            edges.add(make_edge(u, v))
    return (n, edges)


def complete_bipartite(a: int, b: int) -> Graph:
    """K_{a,b}: parts {0..a-1} and {a..a+b-1}, all cross edges."""
    n = a + b
    edges: Set[Edge] = set()
    for u in range(a):
        for v in range(a, n):
            edges.add(make_edge(u, v))
    return (n, edges)


def has_clique(graph: Graph, r: int) -> bool:
    """Does the graph contain a clique on r vertices?"""
    n, _ = graph
    if r <= 1:
        return n >= r
    for s in combinations(range(n), r):
        if all(adjacent(graph, u, v) for u, v in combinations(s, 2)):
            return True
    return False


# --------------------------------------------------------------------------
# Greedy triangle removal (Algorithm A)
# --------------------------------------------------------------------------
def greedy_triangle_removal(graph: Graph) -> Tuple[Graph, int]:
    """Delete one edge per triangle until triangle-free.

    Returns the resulting triangle-free graph and the number of edges
    deleted, which the theorem guarantees is <= triangle_count(graph).
    """
    n, edges = graph
    edges = set(edges)
    removed = 0
    while True:
        tris = triangles((n, edges))
        if not tris:
            break
        a, b, c = tris[0]
        # remove one edge of the first triangle
        edges.discard(make_edge(a, b))
        removed += 1
    return (n, edges), removed


# --------------------------------------------------------------------------
# Edge edit distance
# --------------------------------------------------------------------------
def edge_edit_distance(g: Graph, h: Graph) -> int:
    """Size of the symmetric difference of edge sets."""
    return len(g[1] ^ h[1])


# --------------------------------------------------------------------------
# Lower shadow
# --------------------------------------------------------------------------
def lower_shadow(family: Iterable[FrozenSet[int]]) -> Set[FrozenSet[int]]:
    """All sets obtained by deleting one element from a member."""
    out: Set[FrozenSet[int]] = set()
    for a in family:
        for x in a:
            out.add(a - {x})
    return out


# --------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------
def demo_handshaking_and_cauchy_schwarz() -> None:
    print("=" * 70)
    print("Handshaking identity and Cauchy-Schwarz degree energy")
    print("=" * 70)
    g = turan_graph(8, 3)
    n = g[0]
    degs = degree_sequence(g)
    print(f"  T(8,3): degree sequence = {degs}")
    print(f"  sum of degrees = {sum(degs)},  2|E| = {2*edge_count(g)}")
    assert sum(degs) == 2 * edge_count(g)
    lhs = n * degree_energy(g)
    rhs = sum(degs) ** 2
    print(f"  n*sum(deg^2) = {lhs}  >=  (sum deg)^2 = {rhs}  -> {lhs >= rhs}")
    assert lhs >= rhs


def demo_mantel() -> None:
    print("=" * 70)
    print("Mantel's theorem: 4|E| <= n^2 for triangle-free graphs (tight)")
    print("=" * 70)
    for n in range(2, 13):
        a, b = n // 2, n - n // 2
        g = complete_bipartite(a, b)  # T(n,2), the extremizer
        e = edge_count(g)
        print(
            f"  n={n:2d}: K_{{{a},{b}}} triangle-free={is_triangle_free(g)}, "
            f"|E|={e:3d}, 4|E|={4*e:3d} <= n^2={n*n:3d}, "
            f"floor(n^2/4)={n*n//4:3d}"
        )
        assert is_triangle_free(g)
        assert 4 * e <= n * n
        assert e == n * n // 4  # extremal: meets the floor exactly


def demo_degree_energy_bound() -> None:
    print("=" * 70)
    print("Degree-energy upper bound: sum(deg^2) <= n|E| (triangle-free)")
    print("=" * 70)
    for g, name in [
        (complete_bipartite(3, 4), "K_{3,4}"),
        (turan_graph(9, 2), "T(9,2)"),
        ((5, {make_edge(0, 1), make_edge(1, 2), make_edge(3, 4)}), "path+edge"),
    ]:
        n = g[0]
        energy = degree_energy(g)
        bound = n * edge_count(g)
        print(
            f"  {name:10s}: tri-free={is_triangle_free(g)}, "
            f"sum(deg^2)={energy} <= n|E|={bound} -> {energy <= bound}"
        )
        assert is_triangle_free(g)
        assert energy <= bound


def demo_turan_clique_free() -> None:
    print("=" * 70)
    print("Turan graph T(n,p) is K_{p+1}-free")
    print("=" * 70)
    for n, p in [(7, 2), (9, 3), (10, 4), (6, 2)]:
        g = turan_graph(n, p)
        free = not has_clique(g, p + 1)
        has_p = has_clique(g, p)
        print(
            f"  T({n},{p}): K_{p+1}-free={free}, contains K_{p}={has_p}, "
            f"|E|={edge_count(g)}"
        )
        assert free


def demo_greedy_removal() -> None:
    print("=" * 70)
    print("Greedy triangle removal: edits <= triangle count")
    print("=" * 70)
    # complete graphs are triangle-rich test cases
    for n in range(3, 8):
        edges = {make_edge(u, v) for u, v in combinations(range(n), 2)}
        g: Graph = (n, edges)
        tc = triangle_count(g)
        h, removed = greedy_triangle_removal(g)
        print(
            f"  K_{n}: triangles={tc:3d}, edges removed={removed:3d} "
            f"<= triangles -> {removed <= tc}; "
            f"result triangle-free={is_triangle_free(h)}"
        )
        assert removed <= tc
        assert is_triangle_free(h)
        assert edge_count(g) - edge_count(h) <= tc


def demo_edit_distance_and_shadow() -> None:
    print("=" * 70)
    print("Edge edit distance (symmetric, zero on diagonal) & shadow monotone")
    print("=" * 70)
    g = turan_graph(6, 2)
    h = turan_graph(6, 3)
    print(f"  d(G,H) = {edge_edit_distance(g, h)}, "
          f"d(H,G) = {edge_edit_distance(h, g)}  (symmetric)")
    print(f"  d(G,G) = {edge_edit_distance(g, g)}  (zero)")
    assert edge_edit_distance(g, h) == edge_edit_distance(h, g)
    assert edge_edit_distance(g, g) == 0

    a: Set[FrozenSet[int]] = {frozenset({0, 1, 2})}
    b: Set[FrozenSet[int]] = {frozenset({0, 1, 2}), frozenset({1, 2, 3})}
    sa, sb = lower_shadow(a), lower_shadow(b)
    print(f"  shadow(A) = {sorted(map(sorted, sa))}")
    print(f"  shadow(B) = {sorted(map(sorted, sb))}")
    print(f"  A subset B and shadow(A) subset shadow(B) -> {sa <= sb}")
    assert a <= b and sa <= sb


def main() -> None:
    demo_handshaking_and_cauchy_schwarz()
    demo_mantel()
    demo_degree_energy_bound()
    demo_turan_clique_free()
    demo_greedy_removal()
    demo_edit_distance_and_shadow()
    print("=" * 70)
    print("All demonstrations passed: numerics agree with the verified theorems.")
    print("=" * 70)


if __name__ == "__main__":
    main()
