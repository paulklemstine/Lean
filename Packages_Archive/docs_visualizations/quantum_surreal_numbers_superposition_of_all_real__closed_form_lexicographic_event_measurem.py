from __future__ import annotations
from fractions import Fraction
from typing import Tuple

def lexicographic_measure(n: int, k: int, has_reservoir: bool) -> Tuple[Tuple[Fraction, Fraction], Fraction]:
    if not 0 <= k <= n:
        raise ValueError("invalid visible count")
    exact = (Fraction(1), Fraction(k - n)) if has_reservoir else (Fraction(0), Fraction(k))
    return exact, exact[0]
