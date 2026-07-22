from fractions import Fraction
from typing import Tuple


def padic_valuation(p: int, x: Fraction) -> float:
    if x == 0:
        return float("inf")
    n, d, v = x.numerator, x.denominator, 0
    while n % p == 0:
        n //= p; v += 1
    while d % p == 0:
        d //= p; v -= 1
    return float(v)


def factor_cross_ratio(p: int, a: Fraction, b: Fraction,
                       c: Fraction, d: Fraction) -> Tuple[float, float]:
    """Return (v_p(cross-ratio), alternating sum of local multiplicities).

    Both must be equal by the genus-0 factorization theorem.
    """
    def m(x: Fraction, y: Fraction) -> float:
        return padic_valuation(p, x - y)
    cr = ((a - c) * (b - d)) / ((a - d) * (b - c))
    lhs = padic_valuation(p, cr)
    rhs = m(a, c) + m(b, d) - m(a, d) - m(b, c)
    return lhs, rhs
