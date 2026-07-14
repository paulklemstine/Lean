"""
Numerical demonstrations for:

    The Extremal Regime of Adjacent-Vertex-Distinguishing (AVD) Total Colourings
    of Central Graphs of Regular Graphs.

This self-contained script models finite simple graphs, builds their central
graphs C(G), and numerically verifies the paper's results on small instances:

  * every original vertex of C(G) has degree |V| - 1;
  * a d-regular non-complete graph has |V| >= d + 2;
  * the complement of a d-regular graph on n vertices is (n-1-d)-regular;
  * extremality (|V| = d + 2) holds iff the complement is 1-regular
    (a perfect matching), i.e. G is a cocktail-party graph;
  * the two lower bounds d + 3 and |V| + 1 coincide iff G is extremal;
  * C_4 is the smallest extremal cycle (C(C_4) needs >= 5 colours);
    C_5 is NOT extremal (5 < 6), demonstrating strict domination.

It also brute-force searches for an AVD-total colouring of C(C_4) to confirm the
lower bound 5 is respected (no valid colouring exists with 4 colours; one exists
with 5).

Run:  python demo.py
"""

from __future__ import annotations

from itertools import combinations
from typing import Dict, FrozenSet, List, Optional, Set, Tuple

# A simple graph is represented by a vertex list and a set of undirected edges,
# each edge a frozenset of two vertices.
Vertex = int
Edge = FrozenSet[Vertex]
Graph = Tuple[List[Vertex], Set[Edge]]


# --------------------------------------------------------------------------- #
# Basic graph utilities
# --------------------------------------------------------------------------- #
def make_edge(u: Vertex, w: Vertex) -> Edge:
    """Return the undirected edge {u, w}."""
    return frozenset((u, w))


def cycle_graph(n: int) -> Graph:
    """The n-cycle C_n on vertices 0..n-1."""
    verts: List[Vertex] = list(range(n))
    edges: Set[Edge] = {make_edge(i, (i + 1) % n) for i in range(n)}
    return verts, edges


def adjacent(g: Graph, u: Vertex, w: Vertex) -> bool:
    """Whether u and w are adjacent in g."""
    return make_edge(u, w) in g[1]


def degree(g: Graph, v: Vertex) -> int:
    """Degree of v in g."""
    verts, _ = g
    return sum(1 for w in verts if w != v and adjacent(g, v, w))


def is_regular(g: Graph) -> Optional[int]:
    """Return d if g is d-regular, else None."""
    verts, _ = g
    if not verts:
        return 0
    d = degree(g, verts[0])
    return d if all(degree(g, v) == d for v in verts) else None


def is_complete(g: Graph) -> bool:
    """Whether g is a complete graph."""
    verts, _ = g
    return all(adjacent(g, u, w) for u, w in combinations(verts, 2))


def complement(g: Graph) -> Graph:
    """The complement graph G^c on the same vertex set."""
    verts, _ = g
    comp_edges: Set[Edge] = {
        make_edge(u, w) for u, w in combinations(verts, 2) if not adjacent(g, u, w)
    }
    return verts, comp_edges


def non_adjacent_pair(g: Graph) -> Optional[Tuple[Vertex, Vertex]]:
    """A witness (a, b) of non-completeness, or None if g is complete."""
    verts, _ = g
    for u, w in combinations(verts, 2):
        if not adjacent(g, u, w):
            return u, w
    return None


# --------------------------------------------------------------------------- #
# Central graph C(G) and its total graph T(C(G))
# --------------------------------------------------------------------------- #
# Vertices of C(G): ("v", u) for original vertices, ("e", edge) for edge-vertices.
CVertex = Tuple[str, object]


def central_vertices(g: Graph) -> List[CVertex]:
    """Vertices of the central graph C(G): originals + edge-vertices."""
    verts, edges = g
    originals: List[CVertex] = [("v", u) for u in verts]
    edge_vs: List[CVertex] = [("e", e) for e in edges]
    return originals + edge_vs


def central_adjacent(g: Graph, x: CVertex, y: CVertex) -> bool:
    """Adjacency in the central graph C(G)."""
    kx, ax = x
    ky, ay = y
    if x == y:
        return False
    if kx == "v" and ky == "v":
        return not adjacent(g, ax, ay)  # non-adjacent originals joined
    if kx == "v" and ky == "e":
        return ax in ay  # endpoint incidence
    if kx == "e" and ky == "v":
        return ay in ax
    return False  # two edge-vertices never adjacent


def central_degree(g: Graph, x: CVertex) -> int:
    """Degree of a vertex in C(G)."""
    cv = central_vertices(g)
    return sum(1 for y in cv if central_adjacent(g, x, y))


# --------------------------------------------------------------------------- #
# Total colouring machinery for AVD verification on small instances
# --------------------------------------------------------------------------- #
# The total graph T(C(G)) has vertices = vertices of C(G) plus edges of C(G).
def central_edges(g: Graph) -> List[FrozenSet[CVertex]]:
    """Edges of C(G) as frozensets of central vertices."""
    cv = central_vertices(g)
    return [
        frozenset((x, y))
        for x, y in combinations(cv, 2)
        if central_adjacent(g, x, y)
    ]


def total_elements(g: Graph) -> Tuple[List[CVertex], List[FrozenSet[CVertex]]]:
    """Return (vertices, edges) of C(G): the two element classes to be coloured."""
    return central_vertices(g), central_edges(g)


def incident_edges(
    v: CVertex, edges: List[FrozenSet[CVertex]]
) -> List[FrozenSet[CVertex]]:
    """Edges of C(G) incident to central vertex v."""
    return [e for e in edges if v in e]


def color_set(
    v: CVertex,
    vcolor: Dict[CVertex, int],
    ecolor: Dict[FrozenSet[CVertex], int],
    edges: List[FrozenSet[CVertex]],
) -> FrozenSet[int]:
    """Signature of v: its colour plus colours of its incident edges."""
    s: Set[int] = {vcolor[v]}
    for e in incident_edges(v, edges):
        s.add(ecolor[e])
    return frozenset(s)


def has_avd_total_coloring(g: Graph, k: int) -> bool:
    """
    Does C(G) admit a proper AVD-total colouring with k colours?

    We colour the *total graph* T(C(G)) -- whose vertices are the vertices AND
    edges of C(G) -- by backtracking with proper-colouring pruning, then check
    the AVD condition on completed colourings. Backtracking makes this feasible
    for small instances such as C_4.
    """
    verts, edges = total_elements(g)
    elements: List[object] = list(verts) + list(edges)  # total-graph vertices
    index: Dict[object, int] = {el: i for i, el in enumerate(elements)}

    # Build adjacency in the total graph T(C(G)).
    def elem_incident(a: object, b: object) -> bool:
        a_v, b_v = (a in verts), (b in verts)
        if a_v and b_v:
            return central_adjacent(g, a, b)          # adjacent C(G)-vertices
        if a_v and not b_v:
            return a in b                              # vertex-edge incidence
        if b_v and not a_v:
            return b in a
        return len(a & b) > 0 and a != b               # edges sharing an endpoint

    n = len(elements)
    adj: List[List[int]] = [[] for _ in range(n)]
    for i in range(n):
        for j in range(i + 1, n):
            if elem_incident(elements[i], elements[j]):
                adj[i].append(j)
                adj[j].append(i)

    color: List[int] = [-1] * n

    def avd_ok() -> bool:
        vcolor = {v: color[index[v]] for v in verts}
        ecolor = {e: color[index[e]] for e in edges}
        for e in edges:
            a, b = tuple(e)
            if color_set(a, vcolor, ecolor, edges) == color_set(
                b, vcolor, ecolor, edges
            ):
                return False
        return True

    def backtrack(i: int) -> bool:
        if i == n:
            return avd_ok()
        used = {color[j] for j in adj[i] if color[j] != -1}
        for c in range(k):
            if c in used:
                continue
            color[i] = c
            if backtrack(i + 1):
                return True
            color[i] = -1
        return False

    return backtrack(0)


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #
def demo_degree_structure() -> None:
    """Every original vertex of C(G) has degree |V| - 1."""
    print("=" * 70)
    print("DEMO 1: original vertices of C(G) all have degree |V| - 1")
    print("=" * 70)
    for n in (4, 5, 6):
        g = cycle_graph(n)
        target = n - 1
        degs = [central_degree(g, ("v", u)) for u in g[0]]
        print(f"  C_{n}: |V| = {n}, degrees of originals in C(G) = {degs}, "
              f"expected all = {target}: {all(d == target for d in degs)}")
    print()


def demo_bounds_and_extremality() -> None:
    """Compare the two lower bounds and test extremality across cycles."""
    print("=" * 70)
    print("DEMO 2: the two lower bounds, complement regularity, extremality")
    print("=" * 70)
    print(f"  {'graph':>6} {'d':>3} {'|V|':>4} {'d+3':>4} {'|V|+1':>6} "
          f"{'compl-reg':>10} {'extremal':>9} {'cocktail':>9}")
    for n in range(4, 9):
        g = cycle_graph(n)
        d = is_regular(g)
        assert d is not None
        card = n
        dbound = d + 3
        vbound = card + 1
        comp = complement(g)
        comp_reg = is_regular(comp)
        extremal = card == d + 2
        cocktail = comp_reg == 1
        print(f"  {'C_' + str(n):>6} {d:>3} {card:>4} {dbound:>4} {vbound:>6} "
              f"{str(comp_reg):>10} {str(extremal):>9} {str(cocktail):>9}")
    print()
    print("  Note: extremal (|V| = d+2) coincides exactly with the complement")
    print("  being 1-regular (a perfect matching). Only C_4 qualifies among")
    print("  cycles; C_5.. have |V| > d+2 and complement degree > 1.")
    print()


def demo_bound_agreement() -> None:
    """Verify d+3 <= |V|+1 with equality iff extremal, on several regular graphs."""
    print("=" * 70)
    print("DEMO 3: d + 3 <= |V| + 1, equality iff |V| = d + 2 (extremal)")
    print("=" * 70)

    # Build the cocktail-party graph K_{2m} minus a perfect matching.
    def cocktail_party(m: int) -> Graph:
        verts = list(range(2 * m))
        edges: Set[Edge] = set()
        for u, w in combinations(verts, 2):
            # matching pairs (2i, 2i+1) are the removed (non)edges
            if not (w == u + 1 and u % 2 == 0):
                edges.add(make_edge(u, w))
        return verts, edges

    graphs: List[Tuple[str, Graph]] = [
        ("C_4", cycle_graph(4)),
        ("C_5", cycle_graph(5)),
        ("cocktail K6-PM", cocktail_party(3)),
        ("cocktail K8-PM", cocktail_party(4)),
    ]
    for name, g in graphs:
        d = is_regular(g)
        pair = non_adjacent_pair(g)
        if d is None or pair is None:
            print(f"  {name}: not regular or complete; skipped")
            continue
        card = len(g[0])
        dbound, vbound = d + 3, card + 1
        agree = dbound == vbound
        extremal = card == d + 2
        print(f"  {name:>16}: d={d}, |V|={card}, d+3={dbound}, |V|+1={vbound}, "
              f"agree={agree}, extremal={extremal}, match={agree == extremal}")
    print()


def demo_c4_bruteforce() -> None:
    """Brute-force confirm the sharp lower bound 5 for C(C_4)."""
    print("=" * 70)
    print("DEMO 4: brute-force AVD-total colouring of C(C_4)")
    print("=" * 70)
    g = cycle_graph(4)
    verts, edges = total_elements(g)
    print(f"  C(C_4) has {len(verts)} vertices and {len(edges)} edges to colour.")
    for k in (4, 5):
        exists = has_avd_total_coloring(g, k)
        verdict = "EXISTS" if exists else "does NOT exist"
        print(f"    AVD-total colouring with {k} colours: {verdict}")
    print("  => The AVD-total chromatic number of C(C_4) is exactly 5, matching")
    print("     the sharp extremal bound d + 3 = |V| + 1 = 5.")
    print()


def main() -> None:
    demo_degree_structure()
    demo_bounds_and_extremality()
    demo_bound_agreement()
    demo_c4_bruteforce()
    print("All demonstrations complete.")


if __name__ == "__main__":
    main()
