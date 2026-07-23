from fractions import Fraction
from itertools import combinations
from typing import FrozenSet, List, Set, Tuple

Graph = Tuple[int, Set[FrozenSet[int]]]


def independence_number(g: Graph) -> int:
    """Return alpha(G), the size of a largest independent set, by descending search."""
    n, edges = g

    def independent(subset: Tuple[int, ...]) -> bool:
        return all(frozenset((u, v)) not in edges for u, v in combinations(subset, 2))

    for size in range(n, 0, -1):
        for subset in combinations(range(n), size):
            if independent(subset):
                return size
    return 0


def independence_ratio(g: Graph) -> Fraction:
    """Return i(G) = alpha(G)/n as an exact rational."""
    n, _ = g
    return Fraction(independence_number(g), n)


def fractional_chromatic_lower_bound(g: Graph) -> Fraction:
    """LP lower bound n/alpha(G) on the fractional chromatic number chi_f(G)."""
    n, _ = g
    return Fraction(n, independence_number(g))


def forces_plane_above_four(g: Graph) -> bool:
    """True iff i(G) < 1/4, which forces chi_f(R^2) > 4 when G is a planar unit-distance graph."""
    return independence_ratio(g) < Fraction(1, 4)
