"""
Numerical demonstrations for
"The Independence Ratio and the Fractional Chromatic Number:
 A Sharp 1/4 Threshold for Unit-Distance Graphs".

All routines are self-contained and depend only on the Python standard library.
A graph is represented as (n, edges) where `n` is the number of vertices
(labelled 0..n-1) and `edges` is a set of frozenset({u, v}) pairs.

Key facts demonstrated:
  * Colour-class bound            : n <= k * alpha(G) for any proper k-colouring.
  * Threshold                     : i(G) < 1/4  =>  chi(G) > 4  and  chi_f(G) > 4.
  * Sharpness                     : i(K_k) = 1/k exactly (K_4 sits at 1/4).
  * Scale anchor                  : the unit equilateral triangle has i = 1/3.
  * Fractional LP lower bound     : every fractional colouring has value >= n/alpha.
  * Reciprocal amplification      : a ratio of 1/4 - eps forces chi_f >= 1/(1/4-eps).
"""

from __future__ import annotations

from fractions import Fraction
from itertools import combinations, product
from math import isclose, sqrt
from typing import Dict, FrozenSet, List, Set, Tuple

Graph = Tuple[int, Set[FrozenSet[int]]]


# --------------------------------------------------------------------------- #
# Basic graph utilities
# --------------------------------------------------------------------------- #
def make_graph(n: int, pairs: List[Tuple[int, int]]) -> Graph:
    """Build a graph on vertices 0..n-1 from a list of undirected pairs."""
    edges: Set[FrozenSet[int]] = {frozenset((u, v)) for u, v in pairs if u != v}
    return n, edges


def adjacent(g: Graph, u: int, v: int) -> bool:
    """Return True iff u and v are joined by an edge."""
    _, edges = g
    return frozenset((u, v)) in edges


def is_independent(g: Graph, subset: Tuple[int, ...]) -> bool:
    """A subset is independent iff no two of its vertices are adjacent."""
    return all(not adjacent(g, u, v) for u, v in combinations(subset, 2))


def independence_number(g: Graph) -> int:
    """alpha(G): size of the largest independent set (brute force)."""
    n, _ = g
    best = 0
    for size in range(n, 0, -1):
        for subset in combinations(range(n), size):
            if is_independent(g, subset):
                return size
    return best


def independence_ratio(g: Graph) -> Fraction:
    """i(G) = alpha(G) / n as an exact rational."""
    n, _ = g
    return Fraction(independence_number(g), n)


def independent_sets(g: Graph) -> List[Tuple[int, ...]]:
    """Enumerate all independent sets (including the empty set)."""
    n, _ = g
    out: List[Tuple[int, ...]] = []
    for size in range(0, n + 1):
        for subset in combinations(range(n), size):
            if is_independent(g, subset):
                out.append(subset)
    return out


def chromatic_number(g: Graph) -> int:
    """chi(G): least k admitting a proper k-colouring (brute force)."""
    n, _ = g
    if n == 0:
        return 0
    for k in range(1, n + 1):
        for colouring in product(range(k), repeat=n):
            if all(colouring[u] != colouring[v] for e in g[1] for u, v in [tuple(e)]):
                return k
    return n


# --------------------------------------------------------------------------- #
# Named graphs
# --------------------------------------------------------------------------- #
def complete_graph(k: int) -> Graph:
    """K_k: every pair adjacent."""
    return make_graph(k, list(combinations(range(k), 2)))


def cycle_graph(n: int) -> Graph:
    """C_n: the n-cycle."""
    return make_graph(n, [(i, (i + 1) % n) for i in range(n)])


def unit_distance_graph(points: List[Tuple[float, float]], tol: float = 1e-9) -> Graph:
    """Unit-distance graph of planar points: i ~ j iff |p_i - p_j| = 1."""
    n = len(points)
    pairs: List[Tuple[int, int]] = []
    for i, j in combinations(range(n), 2):
        d = sqrt((points[i][0] - points[j][0]) ** 2 + (points[i][1] - points[j][1]) ** 2)
        if isclose(d, 1.0, abs_tol=tol):
            pairs.append((i, j))
    return make_graph(n, pairs)


# --------------------------------------------------------------------------- #
# The two structural inequalities
# --------------------------------------------------------------------------- #
def colour_class_bound_holds(g: Graph, colouring: List[int]) -> bool:
    """Verify n <= k * alpha(G) for a proper colouring given as a vertex->colour list."""
    n, _ = g
    # sanity: the colouring must be proper
    for e in g[1]:
        u, v = tuple(e)
        if colouring[u] == colouring[v]:
            raise ValueError("supplied colouring is not proper")
    k = len(set(colouring))
    return n <= k * independence_number(g)


def fractional_lower_bound(g: Graph) -> Fraction:
    """The LP lower bound n / alpha(G) on the value of any fractional colouring."""
    n, _ = g
    return Fraction(n, independence_number(g))


def trivial_fractional_value(g: Graph) -> int:
    """Value of the singleton fractional colouring: weight 1 on each singleton => value n."""
    n, _ = g
    return n


def reciprocal_amplification(eps: Fraction) -> Fraction:
    """Lower bound 1/(1/4 - eps) = 4 + 4*eps/(1 - 4*eps) forced by a ratio of 1/4 - eps."""
    return Fraction(1, 1) / (Fraction(1, 4) - eps)


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #
def demo_complete_graph_sharpness() -> None:
    print("=== Sharpness: complete graphs K_k have i(K_k) = 1/k ===")
    for k in range(1, 7):
        g = complete_graph(k)
        ratio = independence_ratio(g)
        chi = chromatic_number(g)
        print(f"  K_{k}: alpha = {independence_number(g)}, "
              f"i = {ratio} (= 1/{k}), chi = {chi}")
    print("  => K_4 sits exactly on the 1/4 frontier.\n")


def demo_equilateral_triangle() -> None:
    print("=== Scale anchor: the unit equilateral triangle ===")
    pts = [(0.0, 0.0), (1.0, 0.0), (0.5, sqrt(3) / 2)]
    g = unit_distance_graph(pts)
    print(f"  edges = {sorted(tuple(sorted(e)) for e in g[1])}")
    print(f"  alpha = {independence_number(g)}, i = {independence_ratio(g)} (= 1/3)")
    print(f"  1/3 = {float(Fraction(1,3)):.4f} > 1/4 = 0.2500\n")


def demo_colour_class_bound() -> None:
    print("=== Colour-class bound  n <= k * alpha(G) ===")
    examples = {
        "C_5 (5-cycle)": cycle_graph(5),
        "K_4": complete_graph(4),
        "C_6 (6-cycle)": cycle_graph(6),
    }
    for name, g in examples.items():
        n, _ = g
        chi = chromatic_number(g)
        alpha = independence_number(g)
        print(f"  {name}: n = {n}, chi = {chi}, alpha = {alpha}, "
              f"k*alpha = {chi*alpha} >= n : {chi*alpha >= n}")
    print()


def demo_fractional_bound() -> None:
    print("=== Fractional LP lower bound  value >= n/alpha ===")
    examples = {
        "K_4": complete_graph(4),
        "C_5 (5-cycle)": cycle_graph(5),
        "K_5": complete_graph(5),
    }
    for name, g in examples.items():
        lb = fractional_lower_bound(g)
        triv = trivial_fractional_value(g)
        gt4 = lb > 4
        print(f"  {name}: n/alpha = {lb} = {float(lb):.4f}, "
              f"trivial value = {triv}, value > 4 forced: {gt4}")
    print("  (i(G) < 1/4  <=>  n/alpha > 4  =>  every fractional colouring costs > 4)\n")


def demo_reciprocal_amplification() -> None:
    print("=== Reciprocal amplification of a 1/4 - eps barrier ===")
    for eps in [Fraction(1, 100), Fraction(1, 40), Fraction(1, 20)]:
        bound = reciprocal_amplification(eps)
        gain = bound - 4
        print(f"  ratio <= 1/4 - {eps}: chi_f(plane) >= {bound} = {float(bound):.4f} "
              f"(gain over 4 = {float(gain):.4f})")
    print()


def demo_hypothetical_sub_quarter_gadget() -> None:
    print("=== A synthetic sub-1/4 gadget forces chi_f > 4 ===")
    # A graph whose independence ratio is below 1/4 forces chi_f > 4.
    # Two disjoint K_5's: n = 10, alpha = 2, i = 1/5 < 1/4.
    n = 10
    pairs = list(combinations(range(5), 2)) + list(combinations(range(5, 10), 2))
    g = make_graph(n, pairs)
    ratio = independence_ratio(g)
    lb = fractional_lower_bound(g)
    print(f"  two disjoint K_5: n = {n}, alpha = {independence_number(g)}, i = {ratio}")
    print(f"  i = {float(ratio):.4f} < 0.25  =>  chi_f >= {lb} = {float(lb):.1f} > 4\n")


if __name__ == "__main__":
    demo_complete_graph_sharpness()
    demo_equilateral_triangle()
    demo_colour_class_bound()
    demo_fractional_bound()
    demo_reciprocal_amplification()
    demo_hypothetical_sub_quarter_gadget()
