from fractions import Fraction
from typing import List, Tuple

def factorize(n: int) -> List[Tuple[int, int]]:
    """Prime factorization as (prime, exponent) pairs."""
    factors: List[Tuple[int, int]] = []
    m, d = n, 2
    while d * d <= m:
        if m % d == 0:
            a = 0
            while m % d == 0:
                m //= d
                a += 1
            factors.append((d, a))
        d += 1 if d == 2 else 2
    if m > 1:
        factors.append((m, 1))
    return factors

def abundancy_prime_power(p: int, a: int) -> Fraction:
    """Closed form A(p^a) = (p^(a+1)-1) / (p^a (p-1))."""
    return Fraction(p ** (a + 1) - 1, p ** a * (p - 1))

def abundancy_via_product(n: int) -> Fraction:
    """A(n) = prod over prime powers A(p^a), by coprime multiplicativity."""
    result = Fraction(1, 1)
    for p, a in factorize(n):
        result *= abundancy_prime_power(p, a)
    return result
