from fractions import Fraction
from itertools import combinations
from typing import Dict, FrozenSet, List, Set, Tuple


def check_fractional_coloring(
    n: int,
    adj: List[Set[int]],
    weighted_sets: Dict[FrozenSet[int], Fraction],
) -> Tuple[bool, Fraction]:
    """Verify a candidate fractional coloring on a graph with adjacency `adj`.
    Checks that every weighted set is independent and nonnegative, and that
    every vertex is covered with total weight at least 1. Returns
    (feasible, total_weight); the total weight upper-bounds chi_f when feasible."""
    for s, w in weighted_sets.items():
        if w < 0:
            return False, Fraction(0)
        if any(v in adj[u] for u, v in combinations(sorted(s), 2)):
            return False, Fraction(0)
    cover: List[Fraction] = [Fraction(0)] * n
    for s, w in weighted_sets.items():
        for v in s:
            cover[v] += w
    feasible: bool = all(c >= 1 for c in cover)
    total: Fraction = sum(weighted_sets.values(), Fraction(0))
    return feasible, total
