from __future__ import annotations
from typing import Dict

Poly = Dict[int, int]


def poly_mul(p: Poly, q: Poly, n: int) -> Poly:
    """Multiply two polynomials with coefficients reduced modulo n."""
    out: Poly = {}
    for e1, c1 in p.items():
        for e2, c2 in q.items():
            out[e1 + e2] = (out.get(e1 + e2, 0) + c1 * c2) % n
    return {e: c for e, c in out.items() if c != 0}


def poly_pow(p: Poly, k: int, n: int) -> Poly:
    """Fast exponentiation of a polynomial modulo n."""
    result: Poly = {0: 1 % n}
    base: Poly = {e: c % n for e, c in p.items() if c % n != 0}
    while k > 0:
        if k & 1:
            result = poly_mul(result, base, n)
        base = poly_mul(base, base, n)
        k >>= 1
    return result


def aks_single_base(n: int, a: int = 1) -> bool:
    """Decide primality of n via the AKS polynomial criterion.

    Returns True iff (X + a)^n == X^n + a in (Z/nZ)[X], which by the
    verified theorem `aks_criterion` holds exactly when n is prime
    (a must be a unit modulo n; a = 1 always works).
    """
    a %= n
    lhs = poly_pow({1: 1, 0: a}, n, n)
    rhs = {e: c % n for e, c in {n: 1, 0: a}.items() if c % n != 0}
    return lhs == rhs
