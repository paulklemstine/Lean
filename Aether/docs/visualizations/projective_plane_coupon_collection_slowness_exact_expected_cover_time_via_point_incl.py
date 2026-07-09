from fractions import Fraction
from itertools import combinations
from typing import List, Set


def cover_count(blocks: List[Set[int]], subset: Set[int]) -> int:
    """Number of blocks that meet the given subset."""
    return sum(1 for b in blocks if b & subset)


def expected_cover_time(blocks: List[Set[int]], n: int) -> Fraction:
    """Exact expected cover time via inclusion-exclusion over all nonempty S."""
    m = len(blocks)
    total = Fraction(0)
    points = list(range(n))
    for size in range(1, n + 1):
        sign = 1 if size % 2 == 1 else -1
        for combo in combinations(points, size):
            subset = set(combo)
            total += Fraction(sign * m, cover_count(blocks, subset))
    return total
