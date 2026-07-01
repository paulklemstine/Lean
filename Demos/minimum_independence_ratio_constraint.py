"""
Numerical demonstrations for the Minimum Independence Ratio Constraint.

This self-contained module illustrates the reciprocal bridge between coloring
and independence in finite graphs:

    * Greedy coloring bound:        chi(G) <= Delta(G) + 1
    * Reciprocal lower bound:       i(G)  >= 1 / chi(G)
    * Degree-sensitive floor:       i(G)  >= 1 / (Delta(G) + 1)
    * Quarter constraint:           Delta(G) <= 3  =>  i(G) >= 1/4

Here i(G) = alpha(G) / n is the independence ratio, alpha(G) the independence
number, chi(G) the chromatic number, and Delta(G) the maximum degree.

Graphs are represented as (n, edges) with vertices 0..n-1 and edges as a set of
frozensets of size two. All routines are exact (integer / Fraction arithmetic).
"""

from __future__ import annotations

from fractions import Fraction
from itertools import combinations
from math import isclose, sqrt
from typing import Dict, FrozenSet, Iterable, List, Set, Tuple

Edge = FrozenSet[int]
Graph = Tuple[int, Set[Edge]]


def make_graph(n: int, edge_list: Iterable[Tuple[int, int]]) -> Graph:
    """Build a simple graph on vertices 0..n-1 from a list of unordered pairs."""
    edges: Set[Edge] = set()
    for u, v in edge_list:
        if u == v:
            raise ValueError("self-loops are not allowed in a simple graph")
        edges.add(frozenset((u, v)))
    return n, edges


def neighbors(graph: Graph, v: int) -> Set[int]:
    """Return the set of vertices adjacent to v."""
    _, edges = graph
    out: Set[int] = set()
    for e in edges:
        if v in e:
            (w,) = e - {v}
            out.add(w)
    return out


def degree(graph: Graph, v: int) -> int:
    """Return the degree of vertex v."""
    return len(neighbors(graph, v))


def max_degree(graph: Graph) -> int:
    """Return the maximum degree Delta(G)."""
    n, _ = graph
    return max((degree(graph, v) for v in range(n)), default=0)


def is_independent(graph: Graph, subset: Iterable[int]) -> bool:
    """Test whether a subset of vertices contains no edge."""
    _, edges = graph
    s = list(subset)
    for u, v in combinations(s, 2):
        if frozenset((u, v)) in edges:
            return False
    return True


def independence_number(graph: Graph) -> int:
    """Compute alpha(G) by exhaustive search (exponential; for small graphs)."""
    n, _ = graph
    best = 0
    for size in range(n, 0, -1):
        for subset in combinations(range(n), size):
            if is_independent(graph, subset):
                return size
    return best


def independence_ratio(graph: Graph) -> Fraction:
    """Return i(G) = alpha(G) / n as an exact fraction."""
    n, _ = graph
    if n == 0:
        raise ValueError("independence ratio is undefined for the empty graph")
    return Fraction(independence_number(graph), n)


def greedy_coloring(graph: Graph, order: List[int] | None = None) -> Dict[int, int]:
    """
    Greedy proper coloring: color each vertex with the least color absent from
    its already-colored neighbors. Uses at most Delta(G)+1 colors.
    """
    n, _ = graph
    if order is None:
        order = list(range(n))
    color: Dict[int, int] = {}
    for v in order:
        used = {color[w] for w in neighbors(graph, v) if w in color}
        c = 0
        while c in used:
            c += 1
        color[v] = c
    return color


def is_proper(graph: Graph, color: Dict[int, int]) -> bool:
    """Verify that a coloring assigns different colors to adjacent vertices."""
    _, edges = graph
    return all(color[u] != color[v] for e in edges for u, v in (tuple(e),))


def chromatic_number(graph: Graph) -> int:
    """Compute chi(G) by trying k = 1, 2, ... colorings exhaustively."""
    n, _ = graph
    if n == 0:
        return 0
    for k in range(1, n + 1):
        if _is_k_colorable(graph, k):
            return k
    return n


def _is_k_colorable(graph: Graph, k: int) -> bool:
    """Backtracking test for k-colorability."""
    n, _ = graph
    color: Dict[int, int] = {}

    def backtrack(v: int) -> bool:
        if v == n:
            return True
        forbidden = {color[w] for w in neighbors(graph, v) if w in color}
        for c in range(k):
            if c not in forbidden:
                color[v] = c
                if backtrack(v + 1):
                    return True
                del color[v]
        return False

    return backtrack(0)


def unit_distance_graph(points: List[Tuple[float, float]], tol: float = 1e-9) -> Graph:
    """
    Build the unit-distance graph of a finite planar point set: an edge joins two
    points whose Euclidean distance is 1 (within tolerance tol).
    """
    n = len(points)
    edges: Set[Edge] = set()
    for i, j in combinations(range(n), 2):
        (xi, yi), (xj, yj) = points[i], points[j]
        d = sqrt((xi - xj) ** 2 + (yi - yj) ** 2)
        if isclose(d, 1.0, abs_tol=tol):
            edges.add(frozenset((i, j)))
    return n, edges


# --------------------------------------------------------------------------- #
# Named example configurations
# --------------------------------------------------------------------------- #

def triangle_K3() -> Graph:
    """Equilateral triangle: complete graph K_3, i = 1/3 = 1/chi."""
    return make_graph(3, [(0, 1), (1, 2), (0, 2)])


def moser_spindle() -> Graph:
    """
    The Moser spindle, built from genuine planar coordinates: two unit rhombi
    sharing the origin, the second rotated so their far tips are a unit apart.
    Yields 7 vertices, 11 edges, alpha = 2, chi = 4, i = 2/7.
    """
    from math import asin, cos, sin

    def rot(p: Tuple[float, float], t: float) -> Tuple[float, float]:
        x, y = p
        return (x * cos(t) - y * sin(t), x * sin(t) + y * cos(t))

    s = sqrt(3) / 2
    base = [(0.0, 0.0), (1.0, 0.0), (0.5, s), (1.5, s)]
    phi = 2 * asin(1 / (2 * sqrt(3)))  # rotation making the two tips unit-distant
    pts = base + [rot(base[1], phi), rot(base[2], phi), rot(base[3], phi)]
    return unit_distance_graph(pts)


def prism_graph() -> Graph:
    """The triangular prism (3-regular): 6 vertices, alpha = 2, chi = 3, Delta = 3."""
    edges = [
        (0, 1), (1, 2), (0, 2),   # top triangle
        (3, 4), (4, 5), (3, 5),   # bottom triangle
        (0, 3), (1, 4), (2, 5),   # vertical rungs
    ]
    return make_graph(6, edges)


def cycle(n: int) -> Graph:
    """The n-cycle C_n."""
    return make_graph(n, [(i, (i + 1) % n) for i in range(n)])


# --------------------------------------------------------------------------- #
# Reporting
# --------------------------------------------------------------------------- #

def report(name: str, graph: Graph) -> None:
    """Print all invariants and verify the certified bounds for one graph."""
    n, edges = graph
    delta = max_degree(graph)
    alpha = independence_number(graph)
    chi = chromatic_number(graph)
    i_g = Fraction(alpha, n)

    greedy = greedy_coloring(graph)
    greedy_colors = len(set(greedy.values()))

    print(f"=== {name} ===")
    print(f"  vertices n            = {n}")
    print(f"  edges                 = {len(edges)}")
    print(f"  max degree Delta      = {delta}")
    print(f"  independence number   = {alpha}")
    print(f"  chromatic number chi  = {chi}")
    print(f"  independence ratio i  = {i_g}  (~ {float(i_g):.4f})")
    print(f"  greedy colors used    = {greedy_colors}  (bound Delta+1 = {delta + 1})")

    # Verifications
    assert is_proper(graph, greedy), "greedy coloring must be proper"
    assert greedy_colors <= delta + 1, "greedy must use <= Delta+1 colors"
    assert chi <= delta + 1, "chi <= Delta+1 (greedy bound)"
    assert n <= chi * alpha, "pigeonhole: n <= chi * alpha"
    assert i_g >= Fraction(1, chi), "i(G) >= 1/chi (reciprocal bound)"
    assert i_g >= Fraction(1, delta + 1), "i(G) >= 1/(Delta+1)"
    if delta <= 3:
        assert i_g >= Fraction(1, 4), "Delta <= 3 => i(G) >= 1/4"
    print("  checks: chi<=Delta+1, i>=1/chi, i>=1/(Delta+1)  [OK]")
    if delta <= 3:
        print("  quarter constraint Delta<=3 => i>=1/4          [OK]")
    print()


def main() -> None:
    print("Minimum Independence Ratio Constraint -- numerical demonstrations\n")

    examples = [
        ("Equilateral triangle K3", triangle_K3()),
        ("Moser spindle", moser_spindle()),
        ("Triangular prism (3-regular)", prism_graph()),
        ("Cycle C4", cycle(4)),
        ("Cycle C5", cycle(5)),
        ("Cycle C6", cycle(6)),
    ]
    for name, g in examples:
        report(name, g)

    # A unit-distance graph built directly from planar coordinates.
    print("Unit-distance graph from coordinates (unit equilateral triangle):")
    pts = [(0.0, 0.0), (1.0, 0.0), (0.5, sqrt(3) / 2)]
    g = unit_distance_graph(pts)
    report("Planar unit triangle", g)

    print("Summary: in every example i(G) >= 1/chi(G) and i(G) >= 1/(Delta+1);")
    print("whenever Delta <= 3, the quarter floor i(G) >= 1/4 holds.")


if __name__ == "__main__":
    main()
