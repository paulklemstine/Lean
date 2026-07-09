from fractions import Fraction
from math import isqrt

def abundancy_via_factors(n: int) -> Fraction:
    """A(n)=sigma(n)/n computed from the prime factorization (multiplicativity)."""
    if n <= 0:
        raise ValueError('n must be positive')
    a: Fraction = Fraction(1, 1)
    m: int = n
    d: int = 2
    while d <= isqrt(m):
        if m % d == 0:
            e: int = 0
            while m % d == 0:
                m //= d
                e += 1
            a *= Fraction(d ** (e + 1) - 1, d ** e * (d - 1))
        d += 1 if d == 2 else 2
    if m > 1:  # remaining prime factor to the first power
        a *= Fraction(m + 1, m)
    return a