from math import inf
from typing import Callable

def interleaving_distance(
    is_interleaved_at: Callable[[float], bool],
    hi: float = 10.0,
    tol: float = 1e-6,
) -> float:
    """Bisection for inf{eps>=0 : eps-interleaved}; +inf if none."""
    if not is_interleaved_at(hi):
        return inf
    lo = 0.0
    while hi - lo > tol:
        mid = 0.5 * (lo + hi)
        if is_interleaved_at(mid):
            hi = mid
        else:
            lo = mid
    return hi