"""
Vertex amalgamation, the independence ratio, and the 1/7 barrier
================================================================

Numerical companion to the paper.  Everything is self-contained: no third-party
imports, no external data.  All graphs are stored as bitmask adjacency lists so
that independence numbers, clique numbers and chromatic numbers can be computed
exactly for the (small) graphs appearing in the theory.

Definitions used throughout
---------------------------
For a finite simple graph G on n vertices:

    alpha(G)  = independence number  = size of a largest set of pairwise
                                       non-adjacent vertices
    i(G)      = alpha(G) / n         = independence ratio
    chi(G)    = chromatic number
    omega(G)  = clique number

G is the 1-sum (vertex amalgamation) of G1 and G2 along the cut vertex v if
G = G1 union G2 (as edge sets), all edges of G1 live inside a side A, all edges
of G2 live inside a side B, A union B is everything, and A intersect B = {v}.
The star amalgam is the m-fold version: m sides, pairwise meeting exactly in v.

The demonstrations below verify, on explicit graphs:

  1. the pigeonhole bound n <= k*alpha and its equality analysis
     (equality iff every colour class is a maximum independent set);
  2. the max-formulas chi(G) = max chi(G_i), omega(G) = max omega(G_i)
     for amalgams, hence closure of weak perfection chi = omega;
  3. the splitting identity |S| + [v in S] = |S ∩ A| + |S ∩ B|;
  4. the independence defect: sum_i |s_i| <= alpha(G) + (m-1);
  5. the failure of the threshold i >= 1/4 under amalgamation:
     two copies of K8 - e, each with i = 1/4, glue to a graph with i = 1/5;
  6. the m-fold family with i = (m+1)/(7m+1) decreasing to 1/7;
  7. the 1/7 barrier: n <= 7*alpha(G) for every star amalgam whose sides have
     at least two vertices and independence density at least 1/4.
"""

from __future__ import annotations

from fractions import Fraction
from itertools import combinations
from typing import Dict, Iterable, List, Sequence, Set, Tuple

# --------------------------------------------------------------------------- #
#  Graph type and basic constructors
# --------------------------------------------------------------------------- #

Graph = Tuple[int, List[Set[int]]]  # (number of vertices, adjacency sets)


def make_graph(n: int, edges: Iterable[Tuple[int, int]]) -> Graph:
    """Build a simple graph on vertices 0..n-1 from an edge list."""
    adj: List[Set[int]] = [set() for _ in range(n)]
    for x, y in edges:
        if x == y:
            raise ValueError("simple graphs have no loops")
        adj[x].add(y)
        adj[y].add(x)
    return (n, adj)


def complete_minus_edge(n: int, missing: Tuple[int, int]) -> Graph:
    """K_n with one edge deleted."""
    a, b = missing
    edges = [
        (x, y)
        for x, y in combinations(range(n), 2)
        if {x, y} != {a, b}
    ]
    return make_graph(n, edges)


def edge_set(g: Graph) -> Set[Tuple[int, int]]:
    n, adj = g
    return {(x, y) for x in range(n) for y in adj[x] if x < y}


def union_graph(g1: Graph, g2: Graph) -> Graph:
    """Edge-union of two graphs on the same vertex set."""
    n1, _ = g1
    n2, _ = g2
    if n1 != n2:
        raise ValueError("graphs must share a vertex set")
    return make_graph(n1, edge_set(g1) | edge_set(g2))


def induced_subgraph(g: Graph, vertices: Sequence[int]) -> Graph:
    """Induced subgraph on the given vertices, relabelled 0..len-1."""
    n, adj = g
    index: Dict[int, int] = {v: k for k, v in enumerate(vertices)}
    edges = [
        (index[x], index[y])
        for x, y in combinations(vertices, 2)
        if y in adj[x]
    ]
    return make_graph(len(vertices), edges)


# --------------------------------------------------------------------------- #
#  Exact invariants (branch and bound, exact for the sizes used here)
# --------------------------------------------------------------------------- #

def _bitmasks(g: Graph) -> List[int]:
    n, adj = g
    return [sum(1 << y for y in adj[x]) for x in range(n)]


def max_independent_set(g: Graph) -> List[int]:
    """A maximum independent set, by branch and bound with a pivot rule.

    Complexity is exponential in the worst case (the problem is NP-hard) but
    the pivoting keeps it instantaneous for the graphs of this paper.
    """
    n, _ = g
    nbr = _bitmasks(g)
    best: List[int] = []

    def popcount(x: int) -> int:
        return bin(x).count("1")

    def expand(candidates: int, current: List[int]) -> None:
        nonlocal best
        if len(current) + popcount(candidates) <= len(best):
            return
        if candidates == 0:
            if len(current) > len(best):
                best = list(current)
            return
        # pivot: branch on a candidate of maximum degree inside the candidate set
        pivot = max(
            (v for v in range(n) if candidates >> v & 1),
            key=lambda v: popcount(nbr[v] & candidates),
        )
        # either the pivot is in the independent set ...
        expand(candidates & ~nbr[pivot] & ~(1 << pivot), current + [pivot])
        # ... or it is not
        expand(candidates & ~(1 << pivot), current)

    expand((1 << n) - 1, [])
    return sorted(best)


def independence_number(g: Graph) -> int:
    return len(max_independent_set(g))


def independence_ratio(g: Graph) -> Fraction:
    n, _ = g
    return Fraction(independence_number(g), n)


def complement(g: Graph) -> Graph:
    n, adj = g
    return make_graph(
        n, [(x, y) for x, y in combinations(range(n), 2) if y not in adj[x]]
    )


def clique_number(g: Graph) -> int:
    return independence_number(complement(g))


def is_colorable(g: Graph, k: int) -> bool:
    """Exact k-colourability test by backtracking with symmetry breaking."""
    n, adj = g
    colour: List[int] = [-1] * n
    order = sorted(range(n), key=lambda v: -len(adj[v]))

    def backtrack(pos: int, used: int) -> bool:
        if pos == n:
            return True
        v = order[pos]
        forbidden = {colour[u] for u in adj[v] if colour[u] >= 0}
        for c in range(min(used + 1, k)):
            if c in forbidden:
                continue
            colour[v] = c
            if backtrack(pos + 1, max(used, c + 1)):
                return True
            colour[v] = -1
        return False

    return n == 0 or backtrack(0, 0)


def chromatic_number(g: Graph) -> int:
    n, _ = g
    for k in range(1, n + 1):
        if is_colorable(g, k):
            return k
    return n


def proper_coloring(g: Graph, k: int) -> List[int]:
    """A proper k-colouring (assumes one exists)."""
    n, adj = g
    colour: List[int] = [-1] * n

    def backtrack(v: int) -> bool:
        if v == n:
            return True
        forbidden = {colour[u] for u in adj[v] if colour[u] >= 0}
        for c in range(k):
            if c in forbidden:
                continue
            colour[v] = c
            if backtrack(v + 1):
                return True
            colour[v] = -1
        return False

    if not backtrack(0):
        raise ValueError(f"graph is not {k}-colourable")
    return colour


# --------------------------------------------------------------------------- #
#  The extremal graphs of the theory
# --------------------------------------------------------------------------- #

def k8_minus_edge() -> Graph:
    """K8 minus the edge {0,1}: eight vertices, alpha = 2, i = 1/4."""
    return complete_minus_edge(8, (0, 1))


def star_k8(m: int) -> Graph:
    """The m-fold star amalgam of K8 - e, all copies glued at vertex 0.

    Vertex set {0, 1, ..., 7m}.  Block b is {7b+1, ..., 7b+7}; the block spans a
    K7, and the cut vertex 0 is joined to every block vertex except the first,
    7b+1.  Hence side b (block plus cut vertex) is a copy of K8 minus an edge.
    """
    n = 7 * m + 1
    edges: List[Tuple[int, int]] = []
    for b in range(m):
        block = list(range(7 * b + 1, 7 * b + 8))
        edges.extend(combinations(block, 2))
        for w in block[1:]:            # 0 is adjacent to all but block[0]
            edges.append((0, w))
    return make_graph(n, edges)


def star_sides(m: int) -> List[List[int]]:
    """The m sides of star_k8(m): cut vertex together with each block."""
    return [[0] + list(range(7 * b + 1, 7 * b + 8)) for b in range(m)]


def glue_two_k8me() -> Tuple[Graph, List[int], List[int]]:
    """Two copies of K8 - e amalgamated at an endpoint of the missing edge.

    Returns the amalgam together with its two sides.  This is star_k8(2).
    """
    return star_k8(2), star_sides(2)[0], star_sides(2)[1]


# --------------------------------------------------------------------------- #
#  Structural checks
# --------------------------------------------------------------------------- #

def splitting_identity(
    subset: Set[int], side_a: Set[int], side_b: Set[int], cut: int
) -> Tuple[int, int]:
    """Both sides of |S| + [v in S] = |S ∩ A| + |S ∩ B|."""
    left = len(subset) + (1 if cut in subset else 0)
    right = len(subset & side_a) + len(subset & side_b)
    return left, right


def independence_defect(
    g: Graph, sides: Sequence[Sequence[int]]
) -> Tuple[int, int, int]:
    """(sum of side independence numbers, alpha(G), the defect m-1)."""
    total = 0
    for side in sides:
        total += independence_number(induced_subgraph(g, list(side)))
    return total, independence_number(g), len(sides) - 1


def amalgam_ratio_floor(r: Fraction) -> Fraction:
    """The conjectured amalgamation floor r/(2-r) of the threshold i >= r."""
    return r / (2 - r)


# --------------------------------------------------------------------------- #
#  Demonstrations
# --------------------------------------------------------------------------- #

def demo_pigeonhole_equality() -> None:
    print("=" * 72)
    print("1.  The pigeonhole bound  n <= k * alpha  and its equality analysis")
    print("=" * 72)
    examples = [
        ("K4                      ", make_graph(4, combinations(range(4), 2)), 4),
        ("C4 (4-cycle)            ", make_graph(4, [(0, 1), (1, 2), (2, 3), (3, 0)]), 2),
        ("P3 (path on 3 vertices) ", make_graph(3, [(0, 1), (1, 2)]), 2),
        ("K8 - e                  ", k8_minus_edge(), 7),
    ]
    for name, g, k in examples:
        n, _ = g
        alpha = independence_number(g)
        colouring = proper_coloring(g, k)
        classes = [colouring.count(c) for c in range(k)]
        balanced = all(size == alpha for size in classes)
        equality = (n == k * alpha)
        print(
            f"  {name} n={n:2d}  k={k}  alpha={alpha}  colour classes={classes}"
        )
        print(
            f"      n <= k*alpha : {n} <= {k * alpha}   equality: {equality}"
            f"   all classes maximum: {balanced}   (agree: {equality == balanced})"
        )
        print(f"      i(G) = {Fraction(alpha, n)}   1/k = {Fraction(1, k)}")
    print()


def demo_max_formulas() -> None:
    print("=" * 72)
    print("2.  Amalgamation acts as a maximum on chi and on omega")
    print("=" * 72)
    # a 1-sum of K4 (on {0,1,2,3}) and C5 (on {3,4,5,6,7}) at the cut vertex 3
    left = make_graph(8, combinations(range(4), 2))
    right = make_graph(8, [(3, 4), (4, 5), (5, 6), (6, 7), (7, 3)])
    g = union_graph(left, right)
    side_a, side_b = list(range(4)), [3, 4, 5, 6, 7]
    ga = induced_subgraph(g, side_a)
    gb = induced_subgraph(g, side_b)
    print(f"  left  part  K4 : chi={chromatic_number(ga)}  omega={clique_number(ga)}")
    print(f"  right part  C5 : chi={chromatic_number(gb)}  omega={clique_number(gb)}")
    print(
        f"  amalgam        : chi={chromatic_number(g)}  omega={clique_number(g)}"
        f"   (max chi = {max(chromatic_number(ga), chromatic_number(gb))},"
        f" max omega = {max(clique_number(ga), clique_number(gb))})"
    )
    # weak perfection is closed: both K4 and K8-e satisfy chi = omega
    p1 = induced_subgraph(k8_minus_edge(), list(range(8)))
    print(
        f"  K8 - e         : chi={chromatic_number(p1)}  omega={clique_number(p1)}"
        f"   (chi = omega: {chromatic_number(p1) == clique_number(p1)})"
    )
    g2 = star_k8(2)
    print(
        f"  glue of two    : chi={chromatic_number(g2)}  omega={clique_number(g2)}"
        f"   (chi = omega: {chromatic_number(g2) == clique_number(g2)})"
    )
    print()


def demo_splitting_identity() -> None:
    print("=" * 72)
    print("3.  The splitting identity  |S| + [v in S] = |S ∩ A| + |S ∩ B|")
    print("=" * 72)
    sides = star_sides(2)
    a, b = set(sides[0]), set(sides[1])
    for subset in [set(), {0}, {1, 8}, {0, 1, 8}, set(range(15))]:
        left, right = splitting_identity(subset, a, b, 0)
        tag = "univ" if len(subset) == 15 else str(sorted(subset))
        print(f"  S = {tag:<18} left = {left:2d}   right = {right:2d}   equal: {left == right}")
    print()


def demo_counterexample() -> None:
    print("=" * 72)
    print("4.  The threshold i >= 1/4 is NOT closed under amalgamation")
    print("=" * 72)
    side = k8_minus_edge()
    print(
        f"  K8 - e     : n=8  alpha={independence_number(side)}"
        f"  i={independence_ratio(side)}  4-colourable: {is_colorable(side, 4)}"
        f"  omega={clique_number(side)}"
    )
    g, side_a, side_b = glue_two_k8me()
    n, _ = g
    alpha = independence_number(g)
    print(
        f"  amalgam    : n={n} alpha={alpha}  i={independence_ratio(g)}"
        f"  maximum independent set {max_independent_set(g)}"
    )
    total, a_g, defect = independence_defect(g, [side_a, side_b])
    print(f"  defect law : |s1|+|s2| = {total} <= alpha + (m-1) = {a_g} + {defect}")
    r = Fraction(1, 4)
    predicted = r - (1 - r) / n
    print(
        f"  sharp bound: i(G) >= r - (1-r)/n = {predicted}"
        f"   actual i(G) = {independence_ratio(g)}"
        f"   attained: {predicted == independence_ratio(g)}"
    )
    print(f"  drop below the threshold: {independence_ratio(g)} < {r}")
    print()


def demo_star_family() -> None:
    print("=" * 72)
    print("5.  The m-fold family: i = (m+1)/(7m+1)  decreasing to 1/7")
    print("=" * 72)
    print("     m      n   alpha        i(G)      i(G)-1/7   defect bound     7*alpha >= n")
    for m in range(1, 9):
        g = star_k8(m)
        n, _ = g
        alpha = independence_number(g)
        ratio = Fraction(alpha, n)
        predicted = Fraction(m + 1, 7 * m + 1)
        gap = ratio - Fraction(1, 7)
        r = Fraction(1, 4)
        defect_bound = r - Fraction(m - 1) * (1 - r) / n
        assert ratio == predicted, "closed form failed"
        assert gap == Fraction(6, 7 * (7 * m + 1)), "gap identity failed"
        print(
            f"  {m:4d} {n:6d} {alpha:6d} {str(ratio):>11}"
            f" {str(gap):>12}  {str(defect_bound):>12}"
            f"        {7 * alpha >= n}"
        )
    print("  the exact identity  i - 1/7 = 6/(7(7m+1))  holds for every m above")
    print()


def demo_seventh_barrier() -> None:
    print("=" * 72)
    print("6.  The 1/7 barrier: n <= 7 alpha for star amalgams of dense sides")
    print("=" * 72)

    def amalgamate(side_graphs: Sequence[Graph]) -> Tuple[Graph, List[List[int]]]:
        """Glue graphs at vertex 0 of each (each side keeps its vertex 0)."""
        offset = 1
        edges: List[Tuple[int, int]] = []
        sides: List[List[int]] = []
        for (ni, adji) in side_graphs:
            label = [0] + [offset + t for t in range(ni - 1)]
            sides.append(label)
            for x in range(ni):
                for y in adji[x]:
                    if x < y:
                        edges.append((label[x], label[y]))
            offset += ni - 1
        return make_graph(offset, edges), sides

    experiments: List[Tuple[str, List[Graph]]] = [
        ("three copies of K8 - e", [complete_minus_edge(8, (0, 1))] * 3),
        ("K8-e, K4-e, K8-e", [
            complete_minus_edge(8, (0, 1)),
            complete_minus_edge(4, (0, 1)),
            complete_minus_edge(8, (0, 1)),
        ]),
        ("four copies of K4 (density 1/4)", [
            make_graph(4, combinations(range(4), 2))
        ] * 4),
        ("K8-e, K2 (an edge), K8-e", [
            complete_minus_edge(8, (0, 1)),
            make_graph(2, [(0, 1)]),
            complete_minus_edge(8, (0, 1)),
        ]),
        ("five copies of K12 - e", [complete_minus_edge(12, (0, 1))] * 5),
    ]
    for name, parts in experiments:
        g, sides = amalgamate(parts)
        n, _ = g
        alpha = independence_number(g)
        densities_ok = all(
            len(side) <= 4 * independence_number(induced_subgraph(g, side))
            for side in sides
        )
        big_enough = all(len(side) >= 2 for side in sides)
        print(
            f"  {name:<34} n={n:3d} alpha={alpha:3d} i={str(Fraction(alpha, n)):>8}"
            f"  hypotheses: {densities_ok and big_enough}"
            f"  n <= 7 alpha: {n <= 7 * alpha}"
            f"  i >= 1/7: {Fraction(alpha, n) >= Fraction(1, 7)}"
        )
    print()
    print("  conjectured floor r/(2-r) of the threshold i >= r:")
    for num, den in [(1, 2), (1, 3), (1, 4), (1, 5), (2, 5)]:
        r = Fraction(num, den)
        print(f"    r = {str(r):>4}   floor r/(2-r) = {amalgam_ratio_floor(r)}")
    print()


def main() -> None:
    demo_pigeonhole_equality()
    demo_max_formulas()
    demo_splitting_identity()
    demo_counterexample()
    demo_star_family()
    demo_seventh_barrier()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
