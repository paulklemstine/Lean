"""
Certified EML fixed-point solver with an a-priori iteration budget.

Given parameters (a, b, c) admitting a contraction certificate on [lo, hi]
with ratio rho < 1, this routine computes the unique fixed point x* of
f(x) = exp(a) * log(b*x + c) to a user-specified tolerance, using the
a-priori error bound  |x_n - x*| <= |x_1 - x_0| * rho^n / (1 - rho)
to choose the number of iterations BEFORE running them.
"""

from __future__ import annotations

import math
from typing import Tuple


def eml_contraction_ratio(a: float, b: float, c: float,
                          lo: float, hi: float) -> float:
    """sup_{x in [lo,hi]} |f'(x)| = sup |exp(a)*b/(b*x+c)|.
    For b > 0 the magnitude is decreasing in x, so the sup is at the endpoint
    with the smallest denominator; we check both endpoints to be safe."""
    d_lo = abs(math.exp(a) * b / (b * lo + c))
    d_hi = abs(math.exp(a) * b / (b * hi + c))
    return max(d_lo, d_hi)


def certified_fixed_point(a: float, b: float, c: float,
                          lo: float, hi: float,
                          x0: float, tol: float = 1e-12
                          ) -> Tuple[float, int, float]:
    """Return (x_star, n_used, rho).

    Raises ValueError if the contraction certificate fails (rho >= 1, or the
    log argument is not positive on the interval, or x0 is outside [lo,hi]).
    """
    if not (lo <= x0 <= hi):
        raise ValueError("x0 must lie in [lo, hi]")
    if b * lo + c <= 0 or b * hi + c <= 0:
        raise ValueError("log argument b*x+c must be positive on [lo, hi]")
    rho = eml_contraction_ratio(a, b, c, lo, hi)
    if rho >= 1.0:
        raise ValueError(f"not a contraction: rho = {rho} >= 1")

    ea = math.exp(a)
    f = lambda x: ea * math.log(b * x + c)

    x1 = f(x0)
    step0 = abs(x1 - x0)
    if step0 == 0.0:
        return x0, 0, rho

    # a-priori budget: smallest n with step0 * rho^n / (1 - rho) <= tol
    n_needed = max(0, math.ceil(
        math.log(tol * (1.0 - rho) / step0) / math.log(rho)))

    x = x0
    for _ in range(n_needed):
        x = f(x)
    return x, n_needed, rho


if __name__ == "__main__":
    xstar, n, rho = certified_fixed_point(1.0, 1.0, 100.0, 0.0, 20.0, 0.0, 1e-12)
    print(f"x* = {xstar:.12f} reached in n = {n} steps (rho = {rho:.6f})")
