from fractions import Fraction
from typing import List, Optional

def gamma_certificate_from_real_roots(pairs: List[Fraction],
                                      minus_one_mult: int) -> Optional[List[Fraction]]:
    """Construct a nonnegative gamma-vector for a palindromic polynomial given as
    a product of reciprocal-root quadratic factors (1 + a_k t + t^2) with a_k >= 2
    (real, nonpositive roots) and `minus_one_mult` factors of (1+t).

    Each factor 1 + a t + t^2 = (a-2) * t + 1 * (1+t)^2 is gamma-positive of order
    2 with gamma-vector [1, a-2] (nonnegative iff a >= 2). Factor (1+t) has gamma
    [1]. We convolve all gamma-vectors together (multiplicative law)."""
    def conv(u: List[Fraction], v: List[Fraction]) -> List[Fraction]:
        out = [Fraction(0)] * (len(u) + len(v) - 1)
        for i, ui in enumerate(u):
            for j, vj in enumerate(v):
                out[i + j] += ui * vj
        return out
    gamma: List[Fraction] = [Fraction(1)]
    for a in pairs:
        if a < 2:
            return None  # roots not real / not nonpositive -> no certificate
        gamma = conv(gamma, [Fraction(1), a - 2])
    for _ in range(minus_one_mult):
        gamma = conv(gamma, [Fraction(1)])
    return gamma
