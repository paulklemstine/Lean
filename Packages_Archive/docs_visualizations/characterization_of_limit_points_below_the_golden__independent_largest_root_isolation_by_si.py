from __future__ import annotations
import math
from typing import List


def _poly_eval(coeffs: List[float], x: float) -> float:
    acc = 0.0
    for c in coeffs:
        acc = acc * x + c
    return acc


def isolate_largest_root(coeffs: List[float], n: int,
                         tol: float = 1e-13) -> float:
    """Isolate the largest root of the path matching polynomial mu(P_n) by
    bisection on the bracket [0, 2). Since mu(P_n)(2) = n+1 > 0 and the largest
    root is 2cos(pi/(n+1)) < 2, the value at 2 is positive; we bracket the sign
    change just below 2 and bisect. Complexity: O(log(1/tol)) evaluations, each
    O(n) by Horner. Serves as an independent check on the closed form.
    """
    hi = 2.0 - 1e-15
    lo = max(0.0, 2.0 * math.cos(math.pi / (n + 1)) - 0.1)
    f_hi = _poly_eval(coeffs, hi)
    while hi - lo > tol:
        mid = 0.5 * (lo + hi)
        if _poly_eval(coeffs, mid) * f_hi > 0.0:
            hi = mid
        else:
            lo = mid
    return 0.5 * (lo + hi)
