from fractions import Fraction
from typing import Optional


def padic_valuation(p: int, x: Fraction) -> float:
    if x == 0:
        return float("inf")
    n, d, v = x.numerator, x.denominator, 0
    while n % p == 0:
        n //= p; v += 1
    while d % p == 0:
        d //= p; v -= 1
    return float(v)


def ultrametric_multiplicity(p: int, x: Fraction, y: Fraction,
                             z: Fraction) -> Optional[float]:
    """Predict m(x,z) from m(x,y), m(y,z) using the ultrametric/isosceles law.

    If the two inner multiplicities differ, m(x,z) is exactly their minimum
    (returned). Otherwise only the lower bound is known (returns None).
    """
    mxy = padic_valuation(p, x - y)
    myz = padic_valuation(p, y - z)
    if mxy != myz:
        return min(mxy, myz)      # isosceles equality
    return None                    # only m(x,z) >= mxy is guaranteed
