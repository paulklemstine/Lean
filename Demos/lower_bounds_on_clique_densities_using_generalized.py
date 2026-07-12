"""
Numerical demonstrations of clique-density lower bounds via the
inclusion-exclusion inverse.

Central inequality (the "overlap rule" / inclusion-exclusion inverse):

    deg(u) + deg(v) <= n + codeg(u, v)

where n is the number of vertices and codeg(u, v) = |N(u) ∩ N(v)| is the
number of common neighbors of u and v.

This script demonstrates, on explicit graphs, the four consequences:
  1. The inclusion-exclusion inverse holds for every pair.
  2. An over-heavy edge (deg u + deg v > n) forces a triangle.
  3. A triangle-free graph has every edge degree-light (deg u + deg v <= n).
  4. The codegree sum over ordered adjacent pairs equals 6 * (#triangles),
     and summing the inverse yields the Goodman-type lower bound.

Run:  python demo.py
"""

from __future__ import annotations

from itertools import combinations
from typing import Dict, List, Optional, Set, Tuple

# A graph is represented as a dict: vertex -> set of neighbors (symmetric).
Graph = Dict[int, Set[int]]


def make_graph(n: int, edges: List[Tuple[int, int]]) -> Graph:
    """Build an undirected simple graph on vertices 0..n-1 from an edge list."""
    g: Graph = {v: set() for v in range(n)}
    for u, v in edges:
        if u == v:
            raise ValueError("no self-loops allowed")
        g[u].add(v)
        g[v].add(u)
    return g


def degree(g: Graph, u: int) -> int:
    """Number of neighbors of u."""
    return len(g[u])


def codegree(g: Graph, u: int, v: int) -> int:
    """Codegree: number of common neighbors |N(u) ∩ N(v)|."""
    return len(g[u] & g[v])


def edges(g: Graph) -> List[Tuple[int, int]]:
    """List of undirected edges (u < v)."""
    return [(u, v) for u in g for v in g[u] if u < v]


def num_triangles(g: Graph) -> int:
    """Exact number of unordered triangles."""
    count = 0
    for a, b, c in combinations(sorted(g), 3):
        if b in g[a] and c in g[a] and c in g[b]:
            count += 1
    return count


def verify_inverse(g: Graph) -> bool:
    """Check deg(u) + deg(v) <= n + codeg(u, v) for every ordered pair."""
    n = len(g)
    for u in g:
        for v in g:
            if degree(g, u) + degree(g, v) > n + codegree(g, u, v):
                return False
    return True


def find_forced_triangle(g: Graph) -> Optional[Tuple[int, int, int]]:
    """
    Scan for an over-heavy edge (deg u + deg v > n); if found, return an
    explicit triangle {u, v, w} guaranteed by the codegree threshold.
    """
    n = len(g)
    for u, v in edges(g):
        if degree(g, u) + degree(g, v) > n:
            common = g[u] & g[v]
            if common:  # guaranteed nonempty by the overlap rule
                w = min(common)
                return (u, v, w)
    return None


def ordered_codegree_sum(g: Graph) -> int:
    """Sum of codeg(u, v) over ordered adjacent pairs (u, v)."""
    return sum(codegree(g, u, v) for u in g for v in g[u])


def goodman_degree_lower_bound(g: Graph) -> float:
    """
    Classical Goodman lower bound on the triangle count derived from the
    summed inverse:  t(G) >= (1/3) * (sum_w deg(w)^2 - n * |E|).
    """
    n = len(g)
    m = len(edges(g))
    sum_sq = sum(degree(g, w) ** 2 for w in g)
    return (sum_sq - n * m) / 3.0


def goodman_edge_lower_bound(g: Graph) -> float:
    """Cauchy-Schwarz weakening:  t(G) >= |E|(4|E| - n^2) / (3n)."""
    n = len(g)
    m = len(edges(g))
    return m * (4 * m - n * n) / (3.0 * n)


def report(name: str, g: Graph) -> None:
    n = len(g)
    m = len(edges(g))
    t = num_triangles(g)
    print(f"=== {name} ===")
    print(f"  vertices n = {n}, edges |E| = {m}, triangles t(G) = {t}")
    print(f"  inclusion-exclusion inverse holds for all pairs: {verify_inverse(g)}")

    tri = find_forced_triangle(g)
    if tri is not None:
        u, v, w = tri
        print(f"  over-heavy edge ({u},{v}) forces triangle "
              f"{{{u},{v},{w}}}  (deg {u}+deg {v} = "
              f"{degree(g,u)+degree(g,v)} > n = {n})")
    else:
        print("  no over-heavy edge; every edge is degree-light "
              "(Mantel local condition holds)")

    cds = ordered_codegree_sum(g)
    print(f"  codegree sum over ordered adjacent pairs = {cds}  "
          f"(should equal 6*t = {6*t}): {cds == 6*t}")

    gdb = goodman_degree_lower_bound(g)
    geb = goodman_edge_lower_bound(g)
    print(f"  Goodman degree bound  t >= {gdb:.3f}   (actual t = {t})")
    print(f"  Goodman edge   bound  t >= {geb:.3f}   (actual t = {t})")
    print()


def complete_graph(n: int) -> Graph:
    return make_graph(n, list(combinations(range(n), 2)))


def complete_bipartite(a: int, b: int) -> Graph:
    n = a + b
    e = [(i, a + j) for i in range(a) for j in range(b)]
    return make_graph(n, e)


def cycle(n: int) -> Graph:
    return make_graph(n, [(i, (i + 1) % n) for i in range(n)])


def main() -> None:
    # 1. Complete graph K5: dense, many over-heavy edges, many triangles.
    report("Complete graph K5", complete_graph(5))

    # 2. Balanced complete bipartite K_{3,3}: the Mantel extremizer,
    #    triangle-free, every edge degree-light.
    report("Complete bipartite K_{3,3} (triangle-free extremizer)",
           complete_bipartite(3, 3))

    # 3. 5-cycle C5: sparse and triangle-free.
    report("5-cycle C5 (triangle-free)", cycle(5))

    # 4. A hand-built dense graph with an over-heavy edge on 6 vertices.
    dense = make_graph(6, [
        (0, 1), (0, 2), (0, 3), (0, 4),
        (1, 2), (1, 3), (1, 4),
        (2, 5), (3, 5),
    ])
    report("Custom dense graph on 6 vertices", dense)

    # 5. Sanity: bound should turn positive exactly past the Mantel threshold.
    print("=== Goodman threshold demonstration (n = 6) ===")
    print("  Mantel threshold  n^2/4 =", 6 * 6 / 4)
    for m_target in range(6, 12):
        # take first m_target edges of K6
        all_e = list(combinations(range(6), 2))[:m_target]
        g = make_graph(6, all_e)
        print(f"  |E| = {m_target:2d}: edge-bound lower = "
              f"{goodman_edge_lower_bound(g):+.3f}, actual t = {num_triangles(g)}")


if __name__ == "__main__":
    main()
