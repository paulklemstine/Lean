from __future__ import annotations
from typing import Callable, List


def prime_factors(n: int) -> List[int]:
    """Distinct prime divisors of n >= 1, ascending."""
    out: List[int] = []
    d, m = 2, n
    while d * d <= m:
        if m % d == 0:
            out.append(d)
            while m % d == 0:
                m //= d
        d += 1
    if m > 1:
        out.append(m)
    return out


def v2(n: int) -> int:
    c = 0
    while n % 2 == 0:
        n //= 2
        c += 1
    return c


def local_term(ell: int, conductor: int, order: Callable[[int], int]) -> int:
    depth = v2((ell * ell - 1) // 8)
    if conductor % ell == 0:
        return 2 ** depth
    if order(ell) % 2 == 0:
        return 2 ** (depth + 1)
    return 0


def global_invariant(D: int, conductor: int, order: Callable[[int], int]) -> int:
    """Lambda(D) = sum over primes ell | D of the local contribution delta(ell)."""
    return sum(local_term(ell, conductor, order) for ell in prime_factors(D))
