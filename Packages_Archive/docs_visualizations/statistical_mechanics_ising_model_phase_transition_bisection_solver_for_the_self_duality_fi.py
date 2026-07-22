from __future__ import annotations
import math
from typing import Callable


def solve_self_dual(iters: int = 80) -> float:
    """Solve sinh(2 beta) = 1 on (0, 1) by bisection.

    f(beta) = sinh(2 beta) - 1 is continuous and strictly increasing,
    with f(0) = -1 < 0 and f(1) > 0, so a unique root exists in (0, 1).
    After n iterations the bracket width (and hence error) is below 2^{-n}.
    Complexity: O(iters) function evaluations; linear convergence.
    """
    f: Callable[[float], float] = lambda b: math.sinh(2.0 * b) - 1.0
    lo, hi = 0.0, 1.0
    flo = f(lo)
    for _ in range(iters):
        mid = 0.5 * (lo + hi)
        fmid = f(mid)
        if (fmid > 0.0) == (flo > 0.0):
            lo, flo = mid, fmid
        else:
            hi = mid
    return 0.5 * (lo + hi)
