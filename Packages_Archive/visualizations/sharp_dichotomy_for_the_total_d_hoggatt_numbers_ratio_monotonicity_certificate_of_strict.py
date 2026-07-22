from __future__ import annotations
from fractions import Fraction
from typing import Callable

def ratios_strictly_increasing(a: Callable[[int], int], upto: int = 16) -> bool:
    """Certify strict log-convexity of a positive sequence by checking that the
    consecutive ratios r(n) = a(n+1)/a(n) are strictly increasing.  By the
    ratio-monotonicity criterion, r(n) < r(n+1) for all n implies
    a(n+1)^2 < a(n) a(n+2) for all n.  Uses exact rational arithmetic."""
    ratios = [Fraction(a(n + 1), a(n)) for n in range(upto)]
    return all(ratios[n] < ratios[n + 1] for n in range(len(ratios) - 1))
