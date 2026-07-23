from __future__ import annotations
from typing import Dict

def factorize(m: int) -> Dict[int, int]:
    """Prime factorization of m as {prime: exponent}."""
    f: Dict[int, int] = {}
    d = 2
    while d * d <= m:
        while m % d == 0:
            f[d] = f.get(d, 0) + 1
            m //= d
        d += 1
    if m > 1:
        f[m] = f.get(m, 0) + 1
    return f

def entry_point_fast(b: int, p: int) -> int:
    """entryPoint of p in b^n - 1, via order(b mod p) using Fermat descent.
    Assumes p is prime and p does not divide b."""
    b %= p
    assert b != 0
    e = p - 1
    for q, a in factorize(p - 1).items():
        e //= q ** a
        g = pow(b, e, p)
        while g != 1:
            g = pow(g, q, p)
            e *= q
    return e
