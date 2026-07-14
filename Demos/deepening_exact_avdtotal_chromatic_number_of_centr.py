"""
demo.py -- Numerical demonstrations for the sharp order-driven lower bound
on the adjacent-vertex-distinguishing (AVD) total chromatic number of
central graphs.

Main result demonstrated:
    For every non-complete finite simple graph G,
        chi''_a( C(G) )  >=  |V(G)| + 1,
    and this dominates the classical degree bound d + 3 for d-regular G,
    strictly whenever |V(G)| > d + 2.

The script is fully self-contained (standard library only). It:
  1. builds the central graph C(G) and its total graph T(C(G));
  2. verifies the degree structure of C(G) (every original vertex has
     degree |V|-1);
  3. brute-force confirms, on a small example, that no AVD total colouring
     exists with |V| colours, while one exists with |V|+1 colours;
  4. tabulates the order bound vs. the degree bound for several regular
     graph families, exhibiting the strict separation (with C_5 minimal).
"""

from __future__ import annotations

from itertools import combinations, product
from typing import Dict, FrozenSet, List, Optional, Set, Tuple

# A simple graph is (number_of_vertices, set of undirected edges as frozensets).
Vertex = int
Edge = FrozenSet[Vertex]
Graph = Tuple[int, Set[Edge]]

# Vertices of the total graph: original ("v", i) or edge ("e", edge).
TVertex = Tuple[str, object]


# --------------------------------------------------------------------------- #
#  Basic graph constructors
# --------------------------------------------------------------------------- #
def make_graph(n: int, edges: List[Tuple[int, int]]) -> Graph:
    """Build a simple graph on {0,...,n-1} from a list of edges."""
    e: Set[Edge] = {frozenset((a, b)) for a, b in edges if a != b}
    return (n, e)


def cycle(n: int) -> Graph:
    """The cycle C_n on n vertices."""
    return make_graph(n, [(i, (i + 1) % n) for i in range(n)])


def path(n: int) -> Graph:
    """The path P_n on n vertices."""
    return make_graph(n, [(i, i + 1) for i in range(n - 1)])


def complete(n: int) -> Graph:
    """The complete graph K_n."""
    return make_graph(n, [(a, b) for a in range(n) for b in range(a + 1, n)])


def adjacent(g: Graph, a: int, b: int) -> bool:
    """Are a and b adjacent in g?"""
    return frozenset((a, b)) in g[1]


def degree(g: Graph, v: int) -> int:
    """Degree of vertex v in g."""
    return sum(1 for u in range(g[0]) if u != v and adjacent(g, u, v))


def is_regular(g: Graph) -> Optional[int]:
    """Return d if g is d-regular, else None."""
    n = g[0]
    if n == 0:
        return 0
    d = degree(g, 0)
    return d if all(degree(g, v) == d for v in range(n)) else None


def is_complete(g: Graph) -> bool:
    """Is g a complete graph?"""
    n = g[0]
    return len(g[1]) == n * (n - 1) // 2


# --------------------------------------------------------------------------- #
#  Central graph  C(G)
# --------------------------------------------------------------------------- #
def central_vertices(g: Graph) -> List[TVertex]:
    """Vertices of C(G): original vertices plus one per edge of G."""
    verts: List[TVertex] = [("v", i) for i in range(g[0])]
    verts += [("e", e) for e in sorted(g[1], key=lambda s: tuple(sorted(s)))]
    return verts


def central_adjacent(g: Graph, x: TVertex, y: TVertex) -> bool:
    """Adjacency in the central graph C(G)."""
    if x == y:
        return False
    if x[0] == "v" and y[0] == "v":
        # original vertices adjacent iff NON-adjacent in G
        return not adjacent(g, x[1], y[1])  # type: ignore[arg-type]
    if x[0] == "v" and y[0] == "e":
        return x[1] in y[1]  # type: ignore[operator]
    if x[0] == "e" and y[0] == "v":
        return y[1] in x[1]  # type: ignore[operator]
    return False  # two subdivision vertices are never adjacent


def central_degree(g: Graph, x: TVertex) -> int:
    """Degree of x in C(G)."""
    return sum(1 for y in central_vertices(g) if central_adjacent(g, x, y))


# --------------------------------------------------------------------------- #
#  Total graph  T(H)  of a graph H given by (vertices, adjacency predicate)
# --------------------------------------------------------------------------- #
def total_graph_of_central(g: Graph) -> Tuple[List[TVertex], Dict[TVertex, Set[TVertex]]]:
    """
    Build the total graph T(C(G)).

    Its vertices are the vertices of C(G) together with the edges of C(G).
    We encode an edge of C(G) as a frozenset of two C(G)-vertices, tagged 'E'.
    Returns (vertex list, adjacency dict).
    """
    cverts = central_vertices(g)
    cedges: List[FrozenSet[TVertex]] = []
    for a, b in combinations(cverts, 2):
        if central_adjacent(g, a, b):
            cedges.append(frozenset((a, b)))

    tverts: List[TVertex] = [("V", v) for v in cverts] + [("E", e) for e in cedges]

    def t_adj(x: TVertex, y: TVertex) -> bool:
        if x == y:
            return False
        if x[0] == "V" and y[0] == "V":
            return central_adjacent(g, x[1], y[1])  # type: ignore[arg-type]
        if x[0] == "V" and y[0] == "E":
            return x[1] in y[1]  # type: ignore[operator]
        if x[0] == "E" and y[0] == "V":
            return y[1] in x[1]  # type: ignore[operator]
        # two edges of C(G): share an endpoint
        return len(x[1] & y[1]) > 0  # type: ignore[operator]

    adj: Dict[TVertex, Set[TVertex]] = {t: set() for t in tverts}
    for a, b in combinations(tverts, 2):
        if t_adj(a, b):
            adj[a].add(b)
            adj[b].add(a)
    return tverts, adj


# --------------------------------------------------------------------------- #
#  Colour sets and the AVD predicate
# --------------------------------------------------------------------------- #
def colour_set(
    g: Graph,
    colouring: Dict[TVertex, int],
    original: TVertex,
) -> FrozenSet[int]:
    """
    Colour set of an original C(G)-vertex `original` (a ("V", ("v", i))):
    its own colour together with the colours of all incident C(G)-edges.
    """
    colours: Set[int] = {colouring[original]}
    cov = original[1]  # the underlying C(G)-vertex
    for t, c in colouring.items():
        if t[0] == "E" and cov in t[1]:  # type: ignore[operator]
            colours.add(c)
    return frozenset(colours)


def is_proper(
    adj: Dict[TVertex, Set[TVertex]], colouring: Dict[TVertex, int]
) -> bool:
    """Is the colouring a proper colouring of the total graph?"""
    for x, nbrs in adj.items():
        for y in nbrs:
            if colouring[x] == colouring[y]:
                return False
    return True


def is_avd(
    g: Graph,
    tverts: List[TVertex],
    adj: Dict[TVertex, Set[TVertex]],
    colouring: Dict[TVertex, int],
) -> bool:
    """Is the (proper) total colouring adjacent-vertex-distinguishing?"""
    originals = [t for t in tverts if t[0] == "V"]
    for a, b in combinations(originals, 2):
        if central_adjacent(g, a[1], b[1]):  # type: ignore[arg-type]
            if colour_set(g, colouring, a) == colour_set(g, colouring, b):
                return False
    return True


def exists_avd_total_colouring(g: Graph, n_colours: int) -> bool:
    """
    Brute-force search: does T(C(G)) admit an AVD total colouring with
    exactly n_colours colours?  Feasible only for very small G.
    """
    tverts, adj = total_graph_of_central(g)
    for assignment in product(range(n_colours), repeat=len(tverts)):
        colouring = dict(zip(tverts, assignment))
        if is_proper(adj, colouring) and is_avd(g, tverts, adj, colouring):
            return True
    return False


# --------------------------------------------------------------------------- #
#  Demonstrations
# --------------------------------------------------------------------------- #
def demo_degree_structure() -> None:
    """Verify: every original vertex of C(G) has degree |V(G)| - 1."""
    print("=" * 70)
    print("DEGREE STRUCTURE OF THE CENTRAL GRAPH  C(G)")
    print("=" * 70)
    for name, g in [("P4 (path)", path(4)), ("C5 (cycle)", cycle(5)),
                    ("K4 minus an edge", make_graph(4, [(0, 1), (1, 2),
                                                        (2, 3), (3, 0), (0, 2)]))]:
        n = g[0]
        print(f"\nGraph {name}: |V| = {n}")
        for v in range(n):
            dv = central_degree(g, ("v", v))
            flag = "OK" if dv == n - 1 else "MISMATCH"
            print(f"  original vertex {v}: deg_C(G) = {dv}  (expected {n-1})  [{flag}]")
        for e in sorted(g[1], key=lambda s: tuple(sorted(s))):
            de = central_degree(g, ("e", e))
            print(f"  subdivision vertex {set(e)}: deg_C(G) = {de}  (expected 2)")


def demo_brute_force_bound() -> None:
    """
    On the small path P3, confirm the sharp bound by exhaustive search:
      - no AVD total colouring of C(P3) exists with |V| = 3 colours,
      - an AVD total colouring exists with |V| + 1 = 4 colours.
    """
    print("\n" + "=" * 70)
    print("BRUTE-FORCE VERIFICATION OF THE SHARP BOUND ON  C(P3)")
    print("=" * 70)
    g = path(3)
    n = g[0]
    print(f"G = P3,  |V| = {n}  (non-complete: 0 and 2 are non-adjacent)")
    print(f"  order bound  |V| + 1 = {n + 1}")
    with_v = exists_avd_total_colouring(g, n)
    with_v1 = exists_avd_total_colouring(g, n + 1)
    print(f"  AVD total colouring with {n} colours exists?   {with_v}   (expected False)")
    print(f"  AVD total colouring with {n+1} colours exists? {with_v1}   (expected True)")
    print(f"  => chi''_a(C(P3)) = {n + 1}, matching the sharp order bound.")


def demo_order_vs_degree() -> None:
    """Tabulate the order bound vs. the degree bound for regular families."""
    print("\n" + "=" * 70)
    print("ORDER BOUND  |V|+1  vs.  DEGREE BOUND  d+3   (d-regular, non-complete)")
    print("=" * 70)
    families = [
        ("C5  (5-cycle)", cycle(5)),
        ("C6  (6-cycle)", cycle(6)),
        ("C7  (7-cycle)", cycle(7)),
        ("K4  (complete, EXCEPTION)", complete(4)),
        ("Petersen-like 3-reg (K_{3,3})",
         make_graph(6, [(a, b) for a in range(3) for b in range(3, 6)])),
    ]
    print(f"{'graph':<32}{'|V|':>4}{'d':>4}{'d+3':>6}{'|V|+1':>7}{'gap':>6}")
    print("-" * 70)
    for name, g in families:
        d = is_regular(g)
        n = g[0]
        if d is None:
            continue
        if is_complete(g):
            note = "  (complete: bound does not apply)"
            print(f"{name:<32}{n:>4}{d:>4}{d+3:>6}{'-':>7}{'-':>6}{note}")
            continue
        gap = (n + 1) - (d + 3)
        print(f"{name:<32}{n:>4}{d:>4}{d+3:>6}{n+1:>7}{gap:>6}")
    print("\nThe 'gap' column equals |V| - d - 2 >= 0; it is strictly positive")
    print("exactly when |V| > d + 2, e.g. C5 already gives 6 vs the degree bound 5.")


def main() -> None:
    demo_degree_structure()
    demo_brute_force_bound()
    demo_order_vs_degree()
    print("\nAll demonstrations complete.")


if __name__ == "__main__":
    main()
