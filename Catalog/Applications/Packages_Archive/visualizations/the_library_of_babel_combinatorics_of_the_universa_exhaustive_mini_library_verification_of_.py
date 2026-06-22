from fractions import Fraction
from itertools import product
from typing import Tuple

def brute_force_stats(b: int, L: int, p: Tuple[int, ...]) -> Tuple[Fraction, Fraction]:
    """Exact (mean occurrences, containment probability) over the whole mini-Library."""
    k = len(p)
    N = b ** L
    total_occ = 0
    total_hit = 0
    for v in product(range(b), repeat=L):
        c = sum(1 for i in range(L - k + 1) if tuple(v[i:i + k]) == p)
        total_occ += c
        if c > 0:
            total_hit += 1
    return Fraction(total_occ, N), Fraction(total_hit, N)