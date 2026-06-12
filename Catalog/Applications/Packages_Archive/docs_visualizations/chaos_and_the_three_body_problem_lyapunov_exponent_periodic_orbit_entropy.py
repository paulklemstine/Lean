from __future__ import annotations
import math
from typing import Tuple

def periodic_orbit_entropy(d: int, n: int) -> Tuple[float, float, float]:
    """Entropy estimate for the degree-d expanding map E_d(x)=d*x mod 1 from its
    period-n point count P = d^n - 1 (Theorem entropy_periodic_growth). Returns
    (estimate, lower_bound, upper_bound) where the squeeze bounds are
    [log d - log 2 / n, log d]; both converge to log d. Complexity: O(1) with
    big-int exponentiation."""
    if d < 2 or n < 1:
        raise ValueError("require d >= 2 and n >= 1")
    p: int = d ** n - 1
    estimate: float = math.log(p) / n
    logd: float = math.log(d)
    return (estimate, logd - math.log(2) / n, logd)
