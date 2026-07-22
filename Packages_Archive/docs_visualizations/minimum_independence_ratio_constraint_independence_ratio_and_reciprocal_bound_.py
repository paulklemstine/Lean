from fractions import Fraction
from itertools import combinations
from typing import Iterable, List, Set, Tuple


def independence_number(n: int, edges: Set[frozenset]) -> int:
    """Maximum size of an independent set (exhaustive; exact for small graphs)."""
    def is_independent(subset: Iterable[int]) -> bool:
        return all(frozenset((u, v)) not in edges
                   for u, v in combinations(subset, 2))

    for size in range(n, 0, -1):
        for subset in combinations(range(n), size):
            if is_independent(subset):
                return size
    return 0


def independence_ratio_and_bounds(n: int, edges: Set[frozenset],
                                  chi: int, delta: int
                                  ) -> Tuple[Fraction, Fraction, Fraction]:
    """
    Return (i(G), 1/chi, 1/(delta+1)). The theorems guarantee
    i(G) >= 1/chi >= 1/(delta+1); when delta <= 3 the last is >= 1/4.
    """
    alpha = independence_number(n, edges)
    i_g = Fraction(alpha, n)
    return i_g, Fraction(1, chi), Fraction(1, delta + 1)
