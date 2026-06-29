import math
from typing import Tuple

def sandwich(g: float, eps: float, accelerated: bool = False) -> Tuple[float, float, float]:
    """Closed-form O(1) evaluation of the sandwich bounds on Nmin.

    Returns (lower, upper, midpoint) where
        lower = (1 - eps) / g_eff
        upper = log(1/eps) / g_eff + 1
    and g_eff = sqrt(g) in the accelerated (Chebyshev / CG) regime, g otherwise.
    """
    if not (0.0 < g < 1.0):
        raise ValueError("g must lie in (0, 1)")
    if not (0.0 < eps < 1.0):
        raise ValueError("eps must lie in (0, 1)")
    g_eff: float = math.sqrt(g) if accelerated else g
    lower: float = (1.0 - eps) / g_eff
    upper: float = math.log(1.0 / eps) / g_eff + 1.0
    return lower, upper, 0.5 * (lower + upper)
