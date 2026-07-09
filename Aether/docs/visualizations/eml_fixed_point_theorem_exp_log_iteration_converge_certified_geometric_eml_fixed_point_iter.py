from __future__ import annotations
import math
from typing import Callable, Tuple

def eml_fixed_point_certified(
    a: float, b: float, c: float, x0: float, rho: float, tol: float
) -> Tuple[float, int, float]:
    """Iterate x_{n+1} = exp(a)*log(b*x_n + c) until the a priori geometric
    error bound |x_n - x*| <= |x1 - x0| * rho^n / (1 - rho) drops below `tol`.

    Returns (x_n, n, bound). Requires 0 <= rho < 1 and a self-mapping interval.
    """
    f: Callable[[float], float] = lambda x: math.exp(a) * math.log(b * x + c)
    x_prev = x0
    x_curr = f(x0)
    step0 = abs(x_curr - x_prev)
    n = 1
    while step0 * rho ** n / (1.0 - rho) > tol:
        x_curr = f(x_curr)
        n += 1
    bound = step0 * rho ** n / (1.0 - rho)
    return x_curr, n, bound
