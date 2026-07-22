from math import gcd
from functools import reduce

def thirty_divides_pow5(a: int) -> bool:
    """Return True iff 30 | a^5 - a, via the coprime primes 2, 3, 5."""
    v = a ** 5 - a
    return all(v % p == 0 for p in (2, 3, 5))

def optimal_universal_divisor(lo: int = 2, hi: int = 60) -> int:
    """gcd over a of (a^5 - a); returns 30, the optimal universal divisor."""
    return reduce(gcd, (a ** 5 - a for a in range(lo, hi + 1)))
