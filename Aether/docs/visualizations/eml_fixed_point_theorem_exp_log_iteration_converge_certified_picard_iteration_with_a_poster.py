from __future__ import annotations
import math
from typing import List, Tuple


def eml(a: float, b: float, c: float, x: float) -> float:
    """EML operator f(x) = exp(a) * log(b*x + c)."""
    return math.exp(a) * math.log(b * x + c)


def picard_certified(
    a: float, b: float, c: float, x0: float, rho: float, eps: float,
    max_iter: int = 10_000,
) -> Tuple[float, int]:
    """Iterate x_{n+1} = f(x_n) until the a posteriori certificate
    (rho/(1-rho)) * |x_{n+1} - x_n| <= eps guarantees |x_cur - x*| <= eps.
    Returns the certified iterate and the number of steps taken."""
    const = rho / (1.0 - rho)
    x_prev = x0
    x_cur = eml(a, b, c, x_prev)
    steps = 1
    while const * abs(x_cur - x_prev) > eps and steps < max_iter:
        x_prev, x_cur = x_cur, eml(a, b, c, x_cur)
        steps += 1
    return x_cur, steps
