from math import gcd
from typing import Dict, List

def is_prime(n: int) -> bool:
    if n < 2:
        return False
    d = 2
    while d * d <= n:
        if n % d == 0:
            return False
        d += 1
    return True

def factorize(n: int) -> Dict[int, int]:
    factors: Dict[int, int] = {}
    d, m = 2, n
    while d * d <= m:
        while m % d == 0:
            factors[d] = factors.get(d, 0) + 1
            m //= d
        d += 1 if d == 2 else 2
    if m > 1:
        factors[m] = factors.get(m, 0) + 1
    return factors

def is_korselt(n: int) -> bool:
    """Decide whether n is a Carmichael number via Korselt's criterion."""
    if n < 2 or is_prime(n):
        return False                       # primes / units are excluded
    factors = factorize(n)
    if any(e > 1 for e in factors.values()):
        return False                       # not squarefree
    return all((n - 1) % (p - 1) == 0 for p in factors)  # (p-1)|(n-1)
