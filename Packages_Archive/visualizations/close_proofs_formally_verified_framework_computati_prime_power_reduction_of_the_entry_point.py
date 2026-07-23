from math import gcd
from typing import List, Tuple


def lcm(a: int, b: int) -> int:
    return a * b // gcd(a, b)


def entry(m: int) -> int:
    if m == 1:
        return 1
    a, b, k = 0, 1, 1
    while b % m != 0:
        a, b = b, (a + b) % m
        k += 1
    return k


def factorize(n: int) -> List[Tuple[int, int]]:
    factors: List[Tuple[int, int]] = []
    d = 2
    while d * d <= n:
        if n % d == 0:
            e = 0
            while n % d == 0:
                n //= d
                e += 1
            factors.append((d, e))
        d += 1
    if n > 1:
        factors.append((n, 1))
    return factors


def entry_via_factors(m: int) -> int:
    """entry(m) computed from prime powers via the join law (Formula 5.2)."""
    result = 1
    for p, e in factorize(m):
        result = lcm(result, entry(p ** e))
    return result
