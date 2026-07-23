from __future__ import annotations
import math
from fractions import Fraction

def mobius(p: int, q: int, r: int, s: int, x: float) -> float:
    return (p * x + q) / (r * x + s)

def image_density_witness(p: int, q: int, r: int, s: int,
                          u: float, v: float) -> float:
    """
    Constructive proof of `mobius_image_dense`: return a quadratic irrational x
    with u < mobius(p,q,r,s)(x) < v, assuming det = p*s - q*r != 0.

    Step 1: pick a rational t with u - sqrt2 < t < v - sqrt2, so w = t + sqrt2
            is a quadratic irrational inside (u, v)  (quadIrr_dense).
    Step 2: pull w back through the adjugate map adj M = [[s,-q],[-r,p]]:
            x = (s*w - q)/(-r*w + p) = mobius(s,-q,-r,p, w).
            The denominator is nonzero (mobius_adjugate_den_ne_zero) and x is a
            quadratic irrational (quadIrr_mobius).
    Then mobius(p,q,r,s, x) = w in (u, v)  (mobius_adjugate_left_inverse).
    """
    assert p * s - q * r != 0, "determinant must be nonzero"
    lo, hi = u - math.sqrt(2.0), v - math.sqrt(2.0)
    t = Fraction((lo + hi) / 2).limit_denominator(10**6)
    if not (lo < float(t) < hi):
        t = (Fraction(lo).limit_denominator(10**6)
             + Fraction(hi).limit_denominator(10**6)) / 2
    w = float(t) + math.sqrt(2.0)
    x = mobius(s, -q, -r, p, w)        # adjugate pull-back
    return x
