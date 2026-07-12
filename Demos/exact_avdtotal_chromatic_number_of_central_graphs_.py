"""
Numerical demonstrations for:

    Exact AVD-total chromatic number of central graphs of regular graphs

This self-contained script builds the central graph C(G) of a simple graph G,
constructs the associated total graph, and verifies the structural facts and
lower bounds discussed in the accompanying article and paper:

  * every subdivision vertex of C(G) has degree 2;
  * every original vertex of C(G) has degree n - 1, where n = |V(G)|;
  * the closed star of a vertex w is a clique of size deg(w) + 1 in the total
    graph, giving the total-chromatic lower bound deg(w) + 1;
  * two adjacent vertices of maximum, equal degree force at least Delta + 2
    colours in any adjacent-vertex-distinguishing (AVD) total colouring, so a
    non-complete regular G yields the lower bound  chi''_a(C(G)) >= n + 1;
  * for the guiding value d + 3 this lower bound is strictly larger whenever
    n > d + 2, refuting the naive conjecture;
  * an exact backtracking solver computes chi''_a for small central graphs and
    confirms  chi''_a(C(K_3)) = 4 = n + 1.

The code uses only the Python standard library.
"""

from __future__ import annotations

from itertools import combinations, product
from typing import Dict, FrozenSet, Iterable, List, Optional, Set, Tuple

# ---------------------------------------------------------------------------
# Graph representation
# ---------------------------------------------------------------------------
# A simple graph is a pair (vertices, edges), where vertices is a sorted list of
# hashable labels and edges is a set of frozenset({u, v}).

Vertex = object
Edge = FrozenSet
Graph = Tuple[List[Vertex], Set[Edge]]


def make_graph(vertices: Iterable[Vertex], edges: Iterable[Tuple[Vertex, Vertex]]) -> Graph:
    """Build a simple graph from a vertex iterable and an edge iterable."""
    vs = list(vertices)
    es = {frozenset(e) for e in edges}
    return vs, es


def degree(g: Graph, v: Vertex) -> int:
    """Degree of vertex v in graph g."""
    _, edges = g
    return sum(1 for e in edges if v in e)


def is_regular(g: Graph) -> Optional[int]:
    """Return the common degree d if g is d-regular, else None."""
    vs, _ = g
    if not vs:
        return None
    degs = {degree(g, v) for v in vs}
    return degs.pop() if len(degs) == 1 else None


def is_complete(g: Graph) -> bool:
    """Test whether g is a complete graph."""
    vs, edges = g
    n = len(vs)
    return len(edges) == n * (n - 1) // 2


def cycle_graph(n: int) -> Graph:
    """The cycle C_n on vertices 0, ..., n-1."""
    return make_graph(range(n), [(i, (i + 1) % n) for i in range(n)])


def complete_graph(n: int) -> Graph:
    """The complete graph K_n on vertices 0, ..., n-1."""
    return make_graph(range(n), combinations(range(n), 2))


# ---------------------------------------------------------------------------
# Central graph  C(G)
# ---------------------------------------------------------------------------
# Vertices of C(G) are tagged:
#   ("o", v)  original vertex v of G
#   ("s", e)  subdivision vertex sitting on edge e = frozenset({u, w}) of G
# Adjacency in C(G):
#   ("o", u) ~ ("o", w)  iff u != w and {u, w} is NOT an edge of G
#   ("o", u) ~ ("s", e)  iff u in e
#   subdivision vertices are pairwise non-adjacent.

CVertex = Tuple[str, object]


def central_graph(g: Graph) -> Tuple[List[CVertex], Set[FrozenSet[CVertex]]]:
    """Construct the central graph C(G)."""
    vs, edges = g
    cverts: List[CVertex] = [("o", v) for v in vs] + [("s", e) for e in edges]
    cedges: Set[FrozenSet[CVertex]] = set()
    for u, w in combinations(vs, 2):
        if frozenset({u, w}) not in edges:
            cedges.add(frozenset({("o", u), ("o", w)}))
    for e in edges:
        for u in e:
            cedges.add(frozenset({("o", u), ("s", e)}))
    return cverts, cedges


def central_degree(cg: Tuple[List[CVertex], Set[FrozenSet[CVertex]]], v: CVertex) -> int:
    """Degree of a vertex in the central graph."""
    _, cedges = cg
    return sum(1 for e in cedges if v in e)


# ---------------------------------------------------------------------------
# Total graph  T(H)
# ---------------------------------------------------------------------------
# Vertices of T(H) are the vertices of H plus the edges of H:
#   ("V", x)  a vertex x of H
#   ("E", e)  an edge e of H
# Two are adjacent iff: two H-vertices adjacent in H, an H-vertex incident to an
# H-edge, or two H-edges sharing an endpoint.

TVertex = Tuple[str, object]


def total_graph(
    verts: List, edges: Set[FrozenSet]
) -> Tuple[List[TVertex], Dict[TVertex, Set[TVertex]]]:
    """Construct the total graph of a simple graph H = (verts, edges)."""
    tv: List[TVertex] = [("V", v) for v in verts] + [("E", e) for e in edges]
    adj: Dict[TVertex, Set[TVertex]] = {x: set() for x in tv}

    def link(a: TVertex, b: TVertex) -> None:
        adj[a].add(b)
        adj[b].add(a)

    edge_list = list(edges)
    # vertex-vertex
    for e in edge_list:
        u, w = tuple(e)
        link(("V", u), ("V", w))
    # vertex-edge incidence
    for e in edge_list:
        for u in e:
            link(("V", u), ("E", e))
    # edge-edge sharing an endpoint
    for e, f in combinations(edge_list, 2):
        if e & f:
            link(("E", e), ("E", f))
    return tv, adj


# ---------------------------------------------------------------------------
# Closed-star clique  ->  total-chromatic lower bound
# ---------------------------------------------------------------------------
def closed_star(edges: Set[FrozenSet], w) -> List[TVertex]:
    """The closed star of w in T(H): w together with its incident edges."""
    star: List[TVertex] = [("V", w)]
    star += [("E", e) for e in edges if w in e]
    return star


def star_is_clique(adj: Dict[TVertex, Set[TVertex]], star: List[TVertex]) -> bool:
    """Verify the closed star is a clique of the total graph."""
    for a, b in combinations(star, 2):
        if b not in adj[a]:
            return False
    return True


# ---------------------------------------------------------------------------
# Exact AVD-total chromatic number by backtracking
# ---------------------------------------------------------------------------
def _proper_ok(
    coloring: Dict[TVertex, int],
    adj: Dict[TVertex, Set[TVertex]],
    x: TVertex,
    c: int,
) -> bool:
    """Can we assign colour c to x without breaking properness of T(H)?"""
    return all(coloring.get(nb) != c for nb in adj[x])


def _color_set(
    coloring: Dict[TVertex, int], edges: Set[FrozenSet], v
) -> FrozenSet[int]:
    """Colour set of vertex v: its colour together with incident edge colours."""
    s = {coloring[("V", v)]}
    for e in edges:
        if v in e:
            s.add(coloring[("E", e)])
    return frozenset(s)


def has_avd_total_coloring(
    verts: List, edges: Set[FrozenSet], k: int
) -> Optional[Dict[TVertex, int]]:
    """
    Search for a proper total colouring of H = (verts, edges) with k colours
    that is adjacent-vertex-distinguishing.  Returns one if it exists, else None.
    """
    tv, adj = total_graph(verts, edges)
    # order the total-graph vertices by descending degree for stronger pruning
    order = sorted(tv, key=lambda x: -len(adj[x]))
    coloring: Dict[TVertex, int] = {}

    def avd_ok() -> bool:
        for e in edges:
            u, w = tuple(e)
            if _color_set(coloring, edges, u) == _color_set(coloring, edges, w):
                return False
        return True

    def backtrack(i: int) -> bool:
        if i == len(order):
            return avd_ok()
        x = order[i]
        # symmetry break: never use a colour larger than 1 + max used so far
        used = max(coloring.values(), default=-1)
        for c in range(min(k, used + 2)):
            if _proper_ok(coloring, adj, x, c):
                coloring[x] = c
                if backtrack(i + 1):
                    return True
                del coloring[x]
        return False

    return dict(coloring) if backtrack(0) else None


def avd_total_chromatic_number(
    verts: List, edges: Set[FrozenSet], hi: int = 12
) -> int:
    """Exact AVD-total chromatic number by trying k = 1, 2, ... , hi."""
    for k in range(1, hi + 1):
        if has_avd_total_coloring(verts, edges, k) is not None:
            return k
    raise RuntimeError("no AVD total colouring found within the search bound")


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------
def demo_degree_structure() -> None:
    print("=" * 70)
    print("DEGREE STRUCTURE OF C(G)")
    print("=" * 70)
    for name, g in [("C_5", cycle_graph(5)), ("K_4", complete_graph(4)),
                    ("Petersen-ish C_6", cycle_graph(6))]:
        n = len(g[0])
        cg = central_graph(g)
        orig_degs = {central_degree(cg, ("o", v)) for v in g[0]}
        sub_degs = {central_degree(cg, ("s", e)) for e in g[1]}
        print(f"\n{name}:  n = {n},  d-regular with d = {is_regular(g)}")
        print(f"  original-vertex degrees in C(G): {orig_degs}  (predicted n-1 = {n-1})")
        print(f"  subdivision-vertex degrees      : {sub_degs}  (predicted 2)")


def demo_conjecture_table() -> None:
    print("\n" + "=" * 70)
    print("LOWER BOUND  n+1  VERSUS THE CONJECTURED VALUE  d+3")
    print("=" * 70)
    print(f"{'graph':<10}{'d':>4}{'n':>5}{'n+1 (proved LB)':>18}{'d+3 (conj.)':>14}{'  verdict'}")
    graphs = [("C_4", cycle_graph(4)), ("C_5", cycle_graph(5)),
              ("C_6", cycle_graph(6)), ("C_7", cycle_graph(7)),
              ("K_4", complete_graph(4)), ("K_5", complete_graph(5))]
    for name, g in graphs:
        d = is_regular(g)
        n = len(g[0])
        lb = n + 1
        conj = d + 3
        if is_complete(g):
            verdict = "complete: conj. not claimed"
        elif lb > conj:
            verdict = "CONJECTURE FALSE (LB > d+3)"
        else:
            verdict = "boundary n=d+2 (LB = d+3)"
        print(f"{name:<10}{d:>4}{n:>5}{lb:>18}{conj:>14}   {verdict}")


def demo_star_clique() -> None:
    print("\n" + "=" * 70)
    print("CLOSED STAR IS A CLIQUE  ->  total-chromatic lower bound deg(w)+1")
    print("=" * 70)
    g = complete_graph(4)
    cg = central_graph(g)
    cverts, cedges = cg
    tv, adj = total_graph(cverts, cedges)
    w = ("o", 0)  # an original vertex of C(K_4), degree n-1 = 3
    star = closed_star(cedges, w)
    print(f"Vertex w = original vertex 0 of C(K_4), degree {central_degree(cg, w)}.")
    print(f"Closed star has {len(star)} elements and is a clique of T(C(G)): "
          f"{star_is_clique(adj, star)}")
    print(f"=> total chromatic number >= {len(star)} = deg(w)+1.")


def demo_exact_avd() -> None:
    print("\n" + "=" * 70)
    print("EXACT AVD-TOTAL CHROMATIC NUMBER OF A SMALL CENTRAL GRAPH")
    print("=" * 70)
    g = complete_graph(3)          # K_3
    n = len(g[0])
    cg = central_graph(g)          # C(K_3) is the 6-cycle
    cverts, cedges = cg
    val = avd_total_chromatic_number(cverts, cedges)
    print(f"G = K_3:  n = {n},  d = {is_regular(g)}.")
    print(f"C(K_3) has {len(cverts)} vertices and {len(cedges)} edges "
          f"(it is the 6-cycle).")
    print(f"Computed AVD-total chromatic number chi''_a(C(K_3)) = {val}.")
    print(f"Conjectured exact value n+1 = {n+1}  =>  match: {val == n + 1}")


def main() -> None:
    demo_degree_structure()
    demo_conjecture_table()
    demo_star_clique()
    demo_exact_avd()
    print("\nAll demonstrations completed.")


if __name__ == "__main__":
    main()
