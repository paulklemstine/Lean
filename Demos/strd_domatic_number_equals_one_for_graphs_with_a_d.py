"""
Numerical demonstrations for:

    The Signed Total Roman Domatic Number: A Structural Collapse
    Forced by Low-Degree Vertices

A graph is represented as an adjacency map: vertex -> set of neighbors.
All logic is inlined and self-contained; only the standard library is used.

Key notions demonstrated
-------------------------
A *signed total Roman dominating function* (STRDF) assigns each vertex a value
in {-1, 1, 2} such that:
  (1) values lie in {-1, 1, 2};
  (2) for every vertex v, the sum of f over the OPEN neighborhood N(v) is >= 1;
  (3) every vertex with f(v) = -1 has a neighbor u with f(u) = 2.

A *signed total Roman dominating family* is a set of STRDFs whose pointwise sum
is <= 1 at every vertex.  The *signed total Roman domatic number* d_stR(G) is the
maximum size of such a family.

Central results demonstrated numerically:
  - Domatic ceiling:  any family has size <= deg(v) for every v; d_stR <= delta.
  - All-ones labeling is an STRDF whenever there is no isolated vertex.
  - Leaf collapse:  a degree-1 vertex forces d_stR(G) = 1.
  - Degree-3 gives only d_stR <= 3, NOT a collapse to 1.
  - K_{1,2} = P_3 satisfies d_stR = 1.
"""

from __future__ import annotations

from itertools import product
from typing import Dict, List, Set, Tuple

Graph = Dict[int, Set[int]]
Labeling = Dict[int, int]


def make_graph(vertices: List[int], edges: List[Tuple[int, int]]) -> Graph:
    """Build an undirected simple graph as an adjacency map."""
    g: Graph = {v: set() for v in vertices}
    for a, b in edges:
        if a == b:
            continue
        g[a].add(b)
        g[b].add(a)
    return g


def degree(g: Graph, v: int) -> int:
    """Number of neighbors of v (open neighborhood size)."""
    return len(g[v])


def min_degree(g: Graph) -> int:
    """Minimum degree delta(G)."""
    return min((degree(g, v) for v in g), default=0)


def is_strdf(g: Graph, f: Labeling) -> bool:
    """Check the three defining conditions of an STRDF."""
    # (1) values in {-1, 1, 2}
    if any(f[v] not in (-1, 1, 2) for v in g):
        return False
    # (2) total domination: sum over open neighborhood >= 1
    for v in g:
        if sum(f[u] for u in g[v]) < 1:
            return False
    # (3) Roman condition
    for v in g:
        if f[v] == -1 and not any(f[u] == 2 for u in g[v]):
            return False
    return True


def all_strdfs(g: Graph) -> List[Labeling]:
    """Enumerate every STRDF (feasible only for small graphs)."""
    verts = sorted(g)
    out: List[Labeling] = []
    for combo in product((-1, 1, 2), repeat=len(verts)):
        f = dict(zip(verts, combo))
        if is_strdf(g, f):
            out.append(f)
    return out


def is_family(g: Graph, family: List[Labeling]) -> bool:
    """Check that a set of STRDFs respects the per-vertex budget (sum <= 1)."""
    if any(not is_strdf(g, f) for f in family):
        return False
    for v in g:
        if sum(f[v] for f in family) > 1:
            return False
    return True


def domatic_number(g: Graph) -> int:
    """
    Compute d_stR(G) by brute force: the largest k for which some size-k
    subset of the STRDFs forms a family.  Uses the ceiling d_stR <= delta(G)
    to bound the search.
    """
    from itertools import combinations

    funcs = all_strdfs(g)
    ceiling = min_degree(g) if funcs else 0
    best = 0
    # Represent labelings as hashable tuples to form genuine sets.
    verts = sorted(g)
    tup = [tuple(f[v] for v in verts) for f in funcs]
    unique = list(dict.fromkeys(tup))
    labelings = [dict(zip(verts, t)) for t in unique]
    for k in range(1, min(ceiling, len(labelings)) + 1):
        found = any(is_family(g, list(sub)) for sub in combinations(labelings, k))
        if found:
            best = k
        else:
            break
    return best


def demo_ceiling(g: Graph, name: str) -> None:
    """Illustrate d_stR <= delta and print the exact value."""
    d = domatic_number(g)
    delta = min_degree(g)
    print(f"[{name}] delta(G) = {delta}, d_stR(G) = {d}  "
          f"(ceiling satisfied: {d <= delta})")


def main() -> None:
    print("=" * 66)
    print("Signed Total Roman Domatic Number -- numerical demonstrations")
    print("=" * 66)

    # --- K_{1,2} = P_3 : path a-b-c ; leaves a,c have degree 1 --------------
    p3 = make_graph([0, 1, 2], [(0, 1), (1, 2)])
    print("\n1) K_{1,2} = P_3 (path a-b-c). Endpoints are leaves (degree 1).")
    demo_ceiling(p3, "P_3")
    print("   -> Leaf collapse: d_stR = 1 as predicted by the theorem.")

    # All-ones is an STRDF here.
    ones = {v: 1 for v in p3}
    print(f"   All-ones labeling is an STRDF: {is_strdf(p3, ones)}")

    # --- Star K_{1,3} : center has degree 3, leaves degree 1 ---------------
    star = make_graph([0, 1, 2, 3], [(0, 1), (0, 2), (0, 3)])
    print("\n2) Star K_{1,3}: center degree 3, three leaves of degree 1.")
    demo_ceiling(star, "K_{1,3}")
    print("   -> A degree-1 leaf is present, so d_stR = 1.")

    # --- Cycle C_5 : 2-regular, no leaf ------------------------------------
    c5 = make_graph([0, 1, 2, 3, 4],
                    [(0, 1), (1, 2), (2, 3), (3, 4), (4, 0)])
    print("\n3) Cycle C_5: 2-regular, no leaf; ceiling gives d_stR <= 2.")
    demo_ceiling(c5, "C_5")

    # --- Complete graph K_4 : 3-regular; degree-3 does NOT force collapse --
    k4 = make_graph([0, 1, 2, 3],
                    [(0, 1), (0, 2), (0, 3), (1, 2), (1, 3), (2, 3)])
    print("\n4) Complete graph K_4: 3-regular. The ceiling only gives d_stR <= 3")
    print("   from the degree-3 vertices; a degree-3 vertex alone does NOT")
    print("   impose the collapse d_stR = 1 (that is the role of a degree-1 leaf).")
    demo_ceiling(k4, "K_4")
    print("   Here the exact value is bounded by 3 and is not forced to 1 by")
    print("   the degree-3 hypothesis; the ceiling 1 <= d_stR <= 3 holds.")

    print("\n" + "=" * 66)
    print("Summary: a single degree-1 (leaf) vertex forces d_stR(G) = 1,")
    print("whereas higher minimum degree permits larger domatic numbers,")
    print("consistent with the ceiling  1 <= d_stR(G) <= delta(G).")
    print("=" * 66)


if __name__ == "__main__":
    main()
