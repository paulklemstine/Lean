from __future__ import annotations
import math

def steps_to_equilibrium(c: float, k: float, x0: float, eps: float) -> int:
    """Number of affine updates x -> c + k*x needed for |x_n - c/(1-k)| < eps.

    Uses |x_n - x*| = k^n * |x0 - x*| with x* = c/(1-k); requires 0 <= k < 1.
    """
    if not (0.0 <= k < 1.0):
        raise ValueError("damping must satisfy 0 <= k < 1")
    star = c / (1.0 - k)
    gap = abs(x0 - star)
    if gap < eps or k == 0.0:
        return 0
    return math.ceil(math.log(eps / gap) / math.log(k))
