from fractions import Fraction
from itertools import combinations
from typing import FrozenSet, List, Sequence

Simplex = FrozenSet[int]
Matrix = Sequence[Sequence[Fraction]]


def all_simplices(n: int) -> List[Simplex]:
    faces: List[Simplex] = []
    for k in range(n + 1):
        for combo in combinations(range(n), k):
            faces.append(frozenset(combo))
    return faces


def diam_weight(d: Matrix, sigma: Simplex) -> Fraction:
    best = Fraction(0)
    for x in sigma:
        for y in sigma:
            best = max(best, d[x][y])
    return best


def simplex_sup_distance(d1: Matrix, d2: Matrix, n: int) -> Fraction:
    """Reference oracle: sup over all 2^n simplices."""
    return max(abs(diam_weight(d1, s) - diam_weight(d2, s))
               for s in all_simplices(n))
