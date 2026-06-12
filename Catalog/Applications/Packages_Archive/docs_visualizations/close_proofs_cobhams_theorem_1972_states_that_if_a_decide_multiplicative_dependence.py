from typing import Dict, Optional, Tuple
from fractions import Fraction
from math import isqrt


def prime_factorization(n: int) -> Dict[int, int]:
    """Prime -> exponent map of n >= 1 by trial division. O(sqrt(n))."""
    if n < 1:
        raise ValueError("n >= 1 required")
    factors: Dict[int, int] = {}
    d = 2
    while d <= isqrt(n):
        while n % d == 0:
            factors[d] = factors.get(d, 0) + 1
            n //= d
        d += 1 if d == 2 else 2
    if n > 1:
        factors[n] = factors.get(n, 0) + 1
    return factors


def mult_dep_witness(j: int, k: int, bound: int = 64) -> Optional[Tuple[int, int]]:
    """Decide MultDep(j, k) exactly; return minimal witness (a, b) with j**a == k**b."""
    if j < 2 or k < 2:
        return (1, 1) if j == k else None
    fj, fk = prime_factorization(j), prime_factorization(k)
    if set(fj) != set(fk):
        return None
    ratio: Optional[Fraction] = None
    for p in fj:
        r = Fraction(fk[p], fj[p])
        if ratio is None:
            ratio = r
        elif r != ratio:
            return None
    assert ratio is not None
    a, b = ratio.numerator, ratio.denominator
    if a <= bound and b <= bound and j ** a == k ** b:
        return (a, b)
    return None
