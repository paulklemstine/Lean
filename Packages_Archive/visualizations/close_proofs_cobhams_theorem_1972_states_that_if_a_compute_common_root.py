from typing import Dict, Optional, Tuple
from math import gcd, isqrt


def prime_factorization(n: int) -> Dict[int, int]:
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


def common_root(j: int, k: int) -> Optional[Tuple[int, int, int]]:
    """Return (g, p, q) with g >= 2, j == g**p, k == g**q if j, k are dependent."""
    fj, fk = prime_factorization(j), prime_factorization(k)
    if set(fj) != set(fk):
        return None
    # proportionality check
    ratios = {(fk[p], fj[p]) for p in fj}
    from fractions import Fraction
    if len({Fraction(n, d) for n, d in ratios}) != 1:
        return None
    g_exp = {p: gcd(fj[p], fk[p]) for p in fj}
    g = 1
    for p, e in g_exp.items():
        g *= p ** e
    pe = next(iter(fj))
    p_exp = fj[pe] // g_exp[pe]
    q_exp = fk[pe] // g_exp[pe]
    if g ** p_exp == j and g ** q_exp == k:
        return (g, p_exp, q_exp)
    return None
