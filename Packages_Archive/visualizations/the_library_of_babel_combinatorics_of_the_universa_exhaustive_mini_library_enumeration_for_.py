from fractions import Fraction
from itertools import product
from typing import Sequence, Tuple

def occurrence_count(volume: Sequence[int], pattern: Sequence[int]) -> int:
    k, L = len(pattern), len(volume)
    return sum(1 for i in range(L - k + 1)
               if all(volume[i + j] == pattern[j] for j in range(k)))

def empirical_statistics(b: int, L: int, pattern: Tuple[int, ...]) -> Tuple[Fraction, Fraction]:
    """Return (empirical expected count, empirical containment frequency)."""
    counts = [occurrence_count(v, pattern) for v in product(range(b), repeat=L)]
    n = b ** L
    expected = Fraction(sum(counts), n)
    contains = Fraction(sum(1 for c in counts if c >= 1), n)
    return expected, contains
