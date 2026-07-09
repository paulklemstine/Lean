from __future__ import annotations
import math
from typing import Callable, Tuple


def eml_operator(a: float, b: float, c: float) -> Callable[[float], float]:
    return lambda x: math.exp(a) * math.log(b * x + c)


def banach_fixed_point_certified(a: float, b: float, c: float,
                                 lo: float, hi: float, x0: float,
                                 rho: float, eps: float) -> Tuple[float, int, float]:
    """Iterate to within a CERTIFIED a priori tolerance eps.

    Returns (x_n, n, bound) where bound = |x1-x0| rho^n /(1-rho) >= |x_n - x*|.
    Convergence is guaranteed because |f'| <= rho < 1 on [lo, hi].
    """
    assert 0.0 <= rho < 1.0 and lo <= x0 <= hi
    f = eml_operator(a, b, c)
    x1 = f(x0)
    d0 = abs(x1 - x0)
    n = 0
    x = x0
    while d0 * rho ** n / (1.0 - rho) > eps:
        x = f(x)
        n += 1
    return x, n, d0 * rho ** n / (1.0 - rho)
