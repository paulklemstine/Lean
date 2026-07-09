from __future__ import annotations
import math
from typing import Callable, List, Tuple


def eml_certified_iteration(
    a: float, b: float, c: float,
    lo: float, hi: float, rho: float,
    x0: float, target_error: float,
) -> Tuple[float, int, List[float]]:
    """Run the EML iteration x_{n+1} = exp(a)*log(b*x_n + c) until the
    a priori Banach error bound guarantees accuracy <= target_error.

    Preconditions (forming an EMLContractionData): lo < hi, 0 <= rho < 1,
    b*x + c > 0 and |exp(a)*b/(b*x+c)| <= rho on [lo, hi], and f maps
    [lo, hi] into itself; x0 in [lo, hi].

    Returns (x_star_estimate, steps_used, sequence).
    """
    f: Callable[[float], float] = lambda x: math.exp(a) * math.log(b * x + c)
    seq: List[float] = [x0]
    x = x0
    x1 = f(x0)
    seq.append(x1)
    c0 = abs(x1 - x0)            # |x1 - x0|, the only measured constant
    x = x1
    n = 1
    # certified bound after n steps: |x_n - x*| <= c0 * rho^n / (1 - rho)
    while c0 * rho ** n / (1.0 - rho) > target_error:
        x = f(x)
        seq.append(x)
        n += 1
    return x, n, seq
