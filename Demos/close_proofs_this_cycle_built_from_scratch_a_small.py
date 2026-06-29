"""
Numerical demonstrations for the formal theory of extremal graphs.

This script illustrates, with concrete finite graphs, every main result of the
accompanying paper:

  * Mantel's theorem               : triangle-free => 4|E| <= n^2
  * The Turan graph T(n,p)         : complete p-partite, (p+1)-clique-free
  * The Cauchy-Schwarz degree bound: n * sum deg^2 >= (sum deg)^2
  * Disjoint neighborhoods         : adjacent vertices in a triangle-free
                                     graph have deg(u)+deg(v) <= n
  * Greedy triangle removal        : edits to triangle-freeness <= #triangles
  * Edge edit distance             : symmetry and self-distance zero
  * Lower-shadow monotonicity      : A subset B  =>  shadow(A) subset shadow(B)

Everything is self-contained: graphs are represented as a vertex count plus a
set of frozenset edges. No third-party libraries are required.
"""

from __future__ import annotations

from itertools import combinations
from math import floor
from typing import Iterable


# --------------------------------------------------------------------------- #
# Graph primitives                                                             #
# --------------------------------------------------------------------------- #

Edge = frozenset           # an edge is a frozenset of two vertices
Graph = tuple              # a graph is (n, set_of_edges)


def make_graph(n: int, edges: Iterable[Iterable[int]]) -> Graph:
    """Build a graph on vertices {0,...,n-1} from an iterable of pairs."""
    eset = {frozenset(e) for e in edges}
    for e in eset:
        assert len(e) == 2 and all(0 <= v < n for v in e), f"bad edge {set(e)}"
    return (n, eset)


def degree(g: Graph, v: int) -> int:
    """Number of neighbors of vertex v."""
    _, edges = g
    return sum(1 for e in edges if v in e)


def degrees(g: Graph) -> list[int]:
    n, _ = g
    return [degree(g, v) for v in range(n)]


def edge_count(g: Graph) -> int:
    return len(g[1])


def triangles(g: Graph) -> list[tuple[int, int, int]]:
    """All ordered triangles a < b < c that are mutually adjacent."""
    n, edges = g
    out = []
    for a, b, c in combinations(range(n), 3):
        if {frozenset((a, b)), frozenset((a, c)), frozenset((b, c))} <= edges:
            out.append((a, b, c))
    return out


def is_triangle_free(g: Graph) -> bool:
    return len(triangles(g)) == 0


def neighbors(g: Graph, v: int) -> set[int]:
    _, edges = g
    return {next(iter(e - {v})) for e in edges if v in e}


# --------------------------------------------------------------------------- #
# Constructions                                                               #
# --------------------------------------------------------------------------- #

def turan_graph(n: int, p: int) -> Graph:
    """Turan graph T(n, p): vertices i,j adjacent iff i % p != j % p."""
    assert p >= 1
    edges = [
        (i, j)
        for i in range(n)
        for j in range(i + 1, n)
        if i % p != j % p
    ]
    return make_graph(n, edges)


def has_clique(g: Graph, r: int) -> bool:
    """Does g contain a clique of size r?"""
    n, edges = g
    for s in combinations(range(n), r):
        if all(frozenset((a, b)) in edges for a, b in combinations(s, 2)):
            return True
    return False


# --------------------------------------------------------------------------- #
# Theorem demonstrations                                                       #
# --------------------------------------------------------------------------- #

def demo_mantel() -> None:
    print("=" * 70)
    print("MANTEL'S THEOREM:  triangle-free  =>  4|E| <= n^2")
    print("=" * 70)
    for n in range(2, 11):
        g = turan_graph(n, 2)                 # balanced complete bipartite
        e = edge_count(g)
        bound = floor(n * n / 4)
        assert is_triangle_free(g)
        assert 4 * e <= n * n
        print(f"  n={n:2d}: |E(T(n,2))| = {e:3d}   floor(n^2/4) = {bound:3d}   "
              f"4|E|={4*e:3d} <= n^2={n*n:3d}   tight={e == bound}")
    print()


def demo_turan_clique_free() -> None:
    print("=" * 70)
    print("TURAN GRAPH:  T(n,p) is (p+1)-clique-free, but has p-cliques")
    print("=" * 70)
    for n, p in [(6, 2), (6, 3), (9, 3), (8, 4)]:
        g = turan_graph(n, p)
        free = not has_clique(g, p + 1)
        has_p = has_clique(g, p)
        print(f"  T({n},{p}): |E|={edge_count(g):3d}   "
              f"has K_{p}={has_p}   K_{p+1}-free={free}")
    print()


def demo_cauchy_schwarz() -> None:
    print("=" * 70)
    print("DEGREE-ENERGY (Cauchy-Schwarz):  n * sum(deg^2) >= (sum deg)^2")
    print("=" * 70)
    examples = [
        ("path P4", make_graph(4, [(0, 1), (1, 2), (2, 3)])),
        ("cycle C5", make_graph(5, [(0, 1), (1, 2), (2, 3), (3, 4), (4, 0)])),
        ("Turan T(7,3)", turan_graph(7, 3)),
    ]
    for name, g in examples:
        n, _ = g
        d = degrees(g)
        lhs = n * sum(x * x for x in d)
        rhs = sum(d) ** 2
        assert lhs >= rhs
        print(f"  {name:14s}: n*sum(deg^2)={lhs:4d} >= (sum deg)^2={rhs:4d}  "
              f"(sum deg = 2|E| = {sum(d)})")
    print()


def demo_disjoint_neighborhoods() -> None:
    print("=" * 70)
    print("TRIANGLE-FREE:  adjacent u,v  =>  deg(u)+deg(v) <= n")
    print("=" * 70)
    g = turan_graph(8, 2)
    n, edges = g
    assert is_triangle_free(g)
    worst = 0
    for e in edges:
        u, v = tuple(e)
        s = degree(g, u) + degree(g, v)
        inter = neighbors(g, u) & neighbors(g, v)
        assert s <= n and inter == set()
        worst = max(worst, s)
    print(f"  T(8,2): every edge has deg(u)+deg(v) <= n=8 "
          f"(max observed = {worst}), and N(u) cap N(v) = empty.")
    print()


def demo_greedy_triangle_removal() -> None:
    print("=" * 70)
    print("GREEDY TRIANGLE REMOVAL:  edits to triangle-free <= #triangles")
    print("=" * 70)

    def greedy_remove(g: Graph) -> tuple[Graph, int]:
        n, edges = (g[0], set(g[1]))
        removed = 0
        while True:
            tri = triangles((n, edges))
            if not tri:
                break
            a, b, c = tri[0]
            edges.discard(frozenset((a, b)))   # delete one edge of the triangle
            removed += 1
        return (n, edges), removed

    examples = [
        ("K4", make_graph(4, combinations(range(4), 2))),
        ("K5", make_graph(5, combinations(range(5), 2))),
        ("two triangles sharing edge",
         make_graph(4, [(0, 1), (0, 2), (1, 2), (1, 3), (2, 3)])),
    ]
    for name, g in examples:
        t0 = len(triangles(g))
        h, removed = greedy_remove(g)
        assert is_triangle_free(h)
        assert edge_count(g) - edge_count(h) <= t0
        print(f"  {name:28s}: #triangles={t0:2d}  edges removed={removed:2d} "
              f"<= #triangles  -> triangle-free={is_triangle_free(h)}")
    print()


def demo_edit_distance() -> None:
    print("=" * 70)
    print("EDGE EDIT DISTANCE:  symmetric, self-distance zero")
    print("=" * 70)

    def edit_distance(g: Graph, h: Graph) -> int:
        return len(g[1] ^ h[1])             # symmetric difference

    g = make_graph(4, [(0, 1), (1, 2), (2, 3)])
    h = make_graph(4, [(0, 1), (2, 3), (0, 3)])
    assert edit_distance(g, h) == edit_distance(h, g)
    assert edit_distance(g, g) == 0
    print(f"  d(G,H)={edit_distance(g,h)}  d(H,G)={edit_distance(h,g)}  "
          f"d(G,G)={edit_distance(g,g)}")
    print()


def demo_lower_shadow() -> None:
    print("=" * 70)
    print("LOWER-SHADOW MONOTONICITY:  A subset B  =>  shadow(A) subset shadow(B)")
    print("=" * 70)

    def lower_shadow(family: set[frozenset]) -> set[frozenset]:
        out: set[frozenset] = set()
        for s in family:
            for x in s:
                out.add(s - {x})
        return out

    A = {frozenset({0, 1, 2})}
    B = {frozenset({0, 1, 2}), frozenset({1, 2, 3})}
    sa, sb = lower_shadow(A), lower_shadow(B)
    assert A <= B and sa <= sb
    print(f"  shadow(A) = {sorted(sorted(s) for s in sa)}")
    print(f"  shadow(B) = {sorted(sorted(s) for s in sb)}")
    print(f"  shadow(A) subset shadow(B): {sa <= sb}")
    print()


def main() -> None:
    demo_mantel()
    demo_turan_clique_free()
    demo_cauchy_schwarz()
    demo_disjoint_neighborhoods()
    demo_greedy_triangle_removal()
    demo_edit_distance()
    demo_lower_shadow()
    print("All demonstrations completed and assertions verified.")


if __name__ == "__main__":
    main()
