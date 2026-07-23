from __future__ import annotations
from math import gcd, lcm
from typing import Callable, Dict, Optional


def factorize(n: int) -> Dict[int, int]:
    """Prime-power factorization of n >= 1 as {prime: exponent}."""
    factors: Dict[int, int] = {}
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors[d] = factors.get(d, 0) + 1
            n //= d
        d += 1
    if n > 1:
        factors[n] = factors.get(n, 0) + 1
    return factors


def entry_point(u: Callable[[int], int], m: int, limit: int = 5000) -> Optional[int]:
    """Least k > 0 with m | u(k); the only place a search is needed."""
    if m == 0:
        return None
    for k in range(1, limit + 1):
        if u(k) % m == 0:
            return k
    return None


def entry_point_via_reduction(u: Callable[[int], int], n: int,
                              limit: int = 5000) -> Optional[int]:
    """
    Compute entry(n) = lcm over prime powers q || n of entry(q)  (Corollary 7.4).
    For an SDS u, this equals the direct entry point but searches only over the
    (much smaller) prime-power moduli.
    """
    if n <= 1:
        return 1 if n == 1 else None
    result = 1
    for p, e in factorize(n).items():
        eq = entry_point(u, p ** e, limit)
        if eq is None:
            return None
        result = lcm(result, eq)
    return result
