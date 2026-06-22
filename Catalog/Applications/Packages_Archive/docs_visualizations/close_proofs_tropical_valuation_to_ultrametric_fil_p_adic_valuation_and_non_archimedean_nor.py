from fractions import Fraction
from math import exp, log


def p_adic_valuation(q: Fraction, p: int) -> int:
    """v_p(q): exponent of p in q = a/b (q != 0)."""
    if q == 0:
        raise ValueError("v_p(0) is +infinity")
    a, b = abs(q.numerator), q.denominator
    k = 0
    while a % p == 0:
        a //= p
        k += 1
    while b % p == 0:
        b //= p
        k -= 1
    return k


def p_adic_norm(q: Fraction, p: int) -> float:
    """|q|_p = p^(-v_p(q)), with |0|_p = 0 (the bridge map t -> p^(-t))."""
    if q == 0:
        return 0.0
    return float(p) ** (-p_adic_valuation(q, p))


def capstone_identity(q: Fraction, p: int) -> bool:
    """|q|_p == exp(-v_p(q) * log p) for q != 0."""
    v = p_adic_valuation(q, p)
    return abs(p_adic_norm(q, p) - exp(-v * log(p))) < 1e-9
