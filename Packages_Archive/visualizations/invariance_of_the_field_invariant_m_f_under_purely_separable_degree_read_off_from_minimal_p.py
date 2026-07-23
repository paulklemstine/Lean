from math import gcd
from functools import reduce
from typing import Dict

Poly = Dict[int, Dict[int, int]]  # X-exponent -> (t-exponent -> coeff in F_p)


def nat_sep_degree(f: Poly, p: int) -> int:
    """m_f = natSepDegree(f) for an irreducible f over a char-p field.

    Writes f(X) = g(X^{p^e}) with g separable, returns deg g = deg f / p^e,
    where p^e is the largest power of p dividing every nonzero X-exponent of f.
    """
    exps = [xe for xe in f if xe != 0]
    if not exps:
        return 0
    g = reduce(gcd, exps)
    e = 0
    while g > 0 and g % p == 0:
        g //= p
        e += 1
    deg = max(f)
    return deg // (p ** e)
