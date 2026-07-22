from __future__ import annotations
from fractions import Fraction
from itertools import combinations
from typing import FrozenSet, Sequence, Set, List

Block = FrozenSet[int]

def coverage_count(blocks: Sequence[Block], subset: Set[int]) -> int:
    """Number of blocks meeting `subset`."""
    return sum(1 for b in blocks if b & subset)

def expected_cover_time(blocks: Sequence[Block], points: Sequence[int]) -> Fraction:
    """Exact expected cover time via inclusion-exclusion over nonempty subsets."""
    num_blocks = len(blocks)
    total = Fraction(0)
    for k in range(1, len(points) + 1):
        sign = 1 if k % 2 == 1 else -1
        for combo in combinations(points, k):
            c = coverage_count(blocks, set(combo))
            if c:
                total += Fraction(sign * num_blocks, c)
    return total
