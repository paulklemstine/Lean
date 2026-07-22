from itertools import combinations
from fractions import Fraction
from math import comb
from typing import List, FrozenSet


def expected_cover_time(n: int, lines: List[FrozenSet[int]]) -> Fraction:
    """Exact expected coverage time E = sum_A (-1)^{|A|+1} / (1 - p_A).

    p_A = (number of lines disjoint from A) / (number of lines). Uses exact
    rational arithmetic so strict comparisons are certified. Complexity is
    O(2^n * |lines|), feasible only for small planes (n up to ~13).
    """
    num_lines = len(lines)
    total = Fraction(0)
    for k in range(1, n + 1):
        sk = Fraction(0)
        for A in combinations(range(n), k):
            target = set(A)
            avoid = sum(1 for ln in lines if target.isdisjoint(ln))
            sk += Fraction(1) / (1 - Fraction(avoid, num_lines))
        total += (-1) ** (k + 1) * sk
    return total
