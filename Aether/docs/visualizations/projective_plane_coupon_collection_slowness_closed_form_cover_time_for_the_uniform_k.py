from fractions import Fraction
from math import comb
from typing import List


def uniform_expected_cover_time(n: int, k: int) -> Fraction:
    """Expected cover time of ALL k-subsets of an n-set, in O(n) terms.

    Uses coverCount(S) = C(n,k) - C(n-|S|,k), which depends only on |S|.
    """
    total_blocks = comb(n, k)
    total = Fraction(0)
    for s in range(1, n + 1):
        c = total_blocks - comb(n - s, k)  # blocks meeting a fixed s-subset
        if c == 0:
            continue
        sign = 1 if s % 2 == 1 else -1
        total += Fraction(sign * comb(n, s) * total_blocks, c)
    return total
