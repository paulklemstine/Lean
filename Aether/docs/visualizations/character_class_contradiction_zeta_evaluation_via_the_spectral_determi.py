import math
from fractions import Fraction


def point_count(r: int) -> int:
    return 2 if r == 0 else (1 << r)


def zeta_closed_form(t: Fraction) -> Fraction:
    """Exact value Z(t) = 1/(1-2t) (valid identity for |t| < 1/2)."""
    return Fraction(1) / (Fraction(1) - 2 * t)


def zeta_series(t: float, terms: int) -> float:
    """Truncated defining series exp(sum_{r=1..terms} N_r t^r / r).
       Converges to 1/(1-2t) at geometric rate |2t|**terms for |t| < 1/2."""
    s = 0.0
    for r in range(1, terms + 1):
        s += point_count(r) * (t ** r) / r
    return math.exp(s)


def zeta_with_tolerance(t: float, tol: float = 1e-12) -> float:
    """Adaptive zeta evaluation: add terms until successive partial sums of the
       exponent change by less than `tol`. Requires |t| < 1/2 to converge."""
    if abs(t) >= 0.5:
        raise ValueError("series diverges for |t| >= 1/2")
    s, prev, r = 0.0, None, 1
    while prev is None or abs(s - prev) > tol:
        prev = s
        s += point_count(r) * (t ** r) / r
        r += 1
    return math.exp(s)
