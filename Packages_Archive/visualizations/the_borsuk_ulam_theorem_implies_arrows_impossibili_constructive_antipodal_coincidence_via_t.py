from typing import Callable
import math


def find_antipodal_coincidence(
    f: Callable[[float], float],
    tol: float = 1e-12,
    max_iter: int = 200,
) -> float:
    """Locate x in [0, pi] with f(x) = f(x + pi) for a continuous
    2*pi-periodic f, realizing the one-dimensional Borsuk-Ulam theorem.

    Method: g(x) = f(x) - f(x + pi) satisfies g(0) = -g(pi), so g has a
    sign change on [0, pi]; bisection converges to a root.
    """
    def g(x: float) -> float:
        return f(x) - f(x + math.pi)

    lo, hi = 0.0, math.pi
    g_lo = g(lo)
    if abs(g_lo) < tol:
        return lo
    for _ in range(max_iter):
        mid = 0.5 * (lo + hi)
        g_mid = g(mid)
        if abs(g_mid) < tol or (hi - lo) < tol:
            return mid
        if (g_lo > 0) != (g_mid > 0):
            hi = mid
        else:
            lo, g_lo = mid, g_mid
    return 0.5 * (lo + hi)
