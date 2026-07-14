"""Numerical demonstrations for the AVD-total chromatic number of central graphs
of regular graphs.

This module is fully self-contained (standard library only). It illustrates:

  1. Construction of the central graph C(G): subdivide every edge once and join
     every pair of non-adjacent original vertices.
  2. The degree identity: every original vertex of C(G) has degree |V| - 1 and
     every subdivision vertex has degree 2.
  3. The vertex-count bound: a d-regular non-complete graph has |V| >= d + 2.
  4. The certified lower bounds for chi''_a(C(G)):
        degree bound        : d + 3
        size-governed bound : |V| + 1  (always >= d + 3, often strictly larger).
  5. A verifier for AVD-total colourings, and a brute-force search on a tiny
     instance confirming the obstruction (no colouring below the bound).

Notation. A graph is given by its vertex count n and a set of undirected edges,
each an ordered pair (u, w) with u < w. The central graph is returned in the same
format, with subdivision vertices numbered n, n+1, ... in edge order.
"""

from __future__ import annotations

from itertools import combinations, product
from typing import Dict, FrozenSet, List, Optional, Set, Tuple

Edge = Tuple[int, int]
Graph = Tuple[int, Set[Edge]]  # (number of vertices, edge set)


# --------------------------------------------------------------------------- #
# Basic graph utilities
# --------------------------------------------------------------------------- #
def normalize_edge(u: int, w: int) -> Edge:
    """Return the canonical ordered representation of the undirected edge {u, w}."""
    return (u, w) if u < w else (w, u)


def degree(graph: Graph, v: int) -> int:
    """Degree of vertex ``v`` in ``graph``."""
    _, edges = graph
    return sum(1 for (a, b) in edges if a == v or b == v)


def is_regular(graph: Graph) -> Optional[int]:
    """Return the common degree ``d`` if ``graph`` is regular, else ``None``."""
    n, _ = graph
    if n == 0:
        return None
    degs = {degree(graph, v) for v in range(n)}
    return next(iter(degs)) if len(degs) == 1 else None


def is_complete(graph: Graph) -> bool:
    """Whether ``graph`` is the complete graph on its vertices."""
    n, edges = graph
    return len(edges) == n * (n - 1) // 2


# --------------------------------------------------------------------------- #
# Central graph construction
# --------------------------------------------------------------------------- #
def central_graph(graph: Graph) -> Tuple[Graph, Dict[Edge, int], List[int]]:
    """Build the central graph C(G).

    Returns the central graph, a map from each original edge to its subdivision
    vertex, and the list of original vertex labels (0 .. n-1). Subdivision
    vertices are numbered n, n+1, ... following the sorted edge order.
    """
    n, edges = graph
    sorted_edges = sorted(edges)
    subdivision: Dict[Edge, int] = {e: n + i for i, e in enumerate(sorted_edges)}

    new_edges: Set[Edge] = set()
    # (a) subdivide each original edge u - s - w
    for (u, w) in sorted_edges:
        s = subdivision[(u, w)]
        new_edges.add(normalize_edge(u, s))
        new_edges.add(normalize_edge(s, w))
    # (b) join every non-adjacent original pair
    for u, w in combinations(range(n), 2):
        if normalize_edge(u, w) not in edges:
            new_edges.add((u, w))

    total_vertices = n + len(sorted_edges)
    originals = list(range(n))
    return (total_vertices, new_edges), subdivision, originals


# --------------------------------------------------------------------------- #
# Lower bounds from the theory
# --------------------------------------------------------------------------- #
def lower_bounds(graph: Graph) -> Dict[str, int]:
    """Certified lower bounds for chi''_a(C(G)) for a regular, non-complete G."""
    n, _ = graph
    d = is_regular(graph)
    if d is None:
        raise ValueError("graph is not regular")
    if is_complete(graph):
        raise ValueError("graph is complete; the theory requires a non-adjacent pair")
    degree_bound = d + 3
    size_bound = n + 1
    return {
        "d": d,
        "num_vertices": n,
        "vertex_count_bound (|V| >= d+2)": d + 2,
        "degree_bound (d+3)": degree_bound,
        "size_bound (|V|+1)": size_bound,
        "best_certified": max(degree_bound, size_bound),
    }


# --------------------------------------------------------------------------- #
# AVD-total colouring verification
# --------------------------------------------------------------------------- #
def total_graph_conflicts(graph: Graph) -> Dict[object, Set[object]]:
    """Adjacency of the total graph T(graph).

    Elements are original vertices ``v`` (int) and edges ``e`` (Edge tuple).
    Returns, for each element, the set of elements that must differ from it.
    """
    n, edges = graph
    elems: List[object] = list(range(n)) + list(edges)
    conflict: Dict[object, Set[object]] = {x: set() for x in elems}

    def add(x: object, y: object) -> None:
        conflict[x].add(y)
        conflict[y].add(x)

    edge_list = list(edges)
    # vertex - vertex (adjacency in graph)
    for (u, w) in edge_list:
        add(u, w)
    # vertex - edge (incidence)
    for e in edge_list:
        a, b = e
        add(a, e)
        add(b, e)
    # edge - edge (shared endpoint)
    for e, f in combinations(edge_list, 2):
        if set(e) & set(f):
            add(e, f)
    return conflict


def color_set(coloring: Dict[object, int], graph: Graph, v: int) -> FrozenSet[int]:
    """Colour set of vertex ``v``: its colour plus the colours of incident edges."""
    _, edges = graph
    cols = {coloring[v]}
    for e in edges:
        if v in e:
            cols.add(coloring[e])
    return frozenset(cols)


def is_avd_total_coloring(coloring: Dict[object, int], graph: Graph) -> bool:
    """Check that ``coloring`` is a proper total colouring that is AVD."""
    conflict = total_graph_conflicts(graph)
    # properness
    for x, neighbours in conflict.items():
        for y in neighbours:
            if coloring[x] == coloring[y]:
                return False
    # adjacent-vertex-distinguishing
    n, edges = graph
    for (u, w) in edges:
        if color_set(coloring, graph, u) == color_set(coloring, graph, w):
            return False
    return True


def has_avd_total_coloring(graph: Graph, num_colors: int) -> bool:
    """Brute-force existence of an AVD-total colouring with ``num_colors`` colours.

    Feasible only for very small graphs; used here to certify the obstruction on
    a tiny instance.
    """
    n, edges = graph
    elements: List[object] = list(range(n)) + list(edges)
    conflict = total_graph_conflicts(graph)

    order = elements  # simple static order; adequate for tiny graphs
    assignment: Dict[object, int] = {}

    def backtrack(i: int) -> bool:
        if i == len(order):
            # properness already enforced incrementally; check AVD
            for (u, w) in edges:
                if color_set(assignment, graph, u) == color_set(assignment, graph, w):
                    return False
            return True
        x = order[i]
        for c in range(num_colors):
            if all(assignment.get(y) != c for y in conflict[x]):
                assignment[x] = c
                if backtrack(i + 1):
                    return True
                del assignment[x]
        return False

    return backtrack(0)


# --------------------------------------------------------------------------- #
# Named example graphs
# --------------------------------------------------------------------------- #
def cycle(n: int) -> Graph:
    """The cycle graph C_n (2-regular for n >= 3)."""
    edges = {normalize_edge(i, (i + 1) % n) for i in range(n)}
    return (n, edges)


def cocktail_party(d_plus_2: int) -> Graph:
    """K_m minus a perfect matching (m = d_plus_2 must be even).

    This is the (m-2)-regular cocktail-party graph on m vertices, the extremal
    family with |V| = d + 2 where the conjectured equality chi''_a = d+3 can hold.
    """
    m = d_plus_2
    assert m % 2 == 0, "cocktail-party graph needs an even number of vertices"
    matching = {normalize_edge(2 * i, 2 * i + 1) for i in range(m // 2)}
    edges = {normalize_edge(u, w) for u, w in combinations(range(m), 2)} - matching
    return (m, edges)


# --------------------------------------------------------------------------- #
# Demonstration driver
# --------------------------------------------------------------------------- #
def demonstrate(graph: Graph, name: str) -> None:
    """Print all structural facts and lower bounds for ``graph``."""
    n, edges = graph
    d = is_regular(graph)
    print(f"=== {name} ===")
    print(f"  vertices: {n}, edges: {len(edges)}, regular degree d = {d}, "
          f"complete: {is_complete(graph)}")

    cg, subdivision, originals = central_graph(graph)
    cn, cedges = cg
    print(f"  central graph C(G): {cn} vertices, {len(cedges)} edges")

    # degree identity
    orig_degs = {degree(cg, v) for v in originals}
    sub_degs = {degree(cg, s) for s in subdivision.values()}
    print(f"  degree of original vertices in C(G): {orig_degs} "
          f"(expected {{{n - 1}}} = |V| - 1)")
    print(f"  degree of subdivision vertices in C(G): {sub_degs} (expected {{2}})")

    if d is not None and not is_complete(graph):
        lb = lower_bounds(graph)
        print(f"  |V| >= d + 2 ?  {n} >= {d + 2}  -> {n >= d + 2}")
        print(f"  degree bound  chi''_a(C(G)) >= d + 3      = {lb['degree_bound (d+3)']}")
        print(f"  size bound    chi''_a(C(G)) >= |V| + 1    = {lb['size_bound (|V|+1)']}")
        print(f"  best certified lower bound                 = {lb['best_certified']}")
    print()


def main() -> None:
    # Cycles: d = 2 always, but |V| grows, so the size bound overtakes d + 3.
    for k in (5, 6, 7):
        demonstrate(cycle(k), f"C_{k} (five-cycle family)")

    # Cocktail-party graph K_6 minus a perfect matching: |V| = d + 2 (extremal).
    demonstrate(cocktail_party(6), "K_6 minus perfect matching (d = 4, |V| = 6)")

    # Brute-force certification of the obstruction on the smallest instance.
    print("=== Brute-force obstruction check on C(C_4) ===")
    # C_4 is 2-regular, not complete; |V| = 4 = d + 2 (extremal for d = 2).
    g4 = cycle(4)
    cg4, _, _ = central_graph(g4)
    # size bound = |V| + 1 = 5; verify no AVD-total colouring with 4 colours.
    for palette in (3, 4, 5):
        ok = has_avd_total_coloring(cg4, palette)
        print(f"  AVD-total colouring of C(C_4) with {palette} colours exists? {ok}")
    print("  (theory predicts: impossible for <= 4, the first success at 5 = |V|+1)")


if __name__ == "__main__":
    main()
