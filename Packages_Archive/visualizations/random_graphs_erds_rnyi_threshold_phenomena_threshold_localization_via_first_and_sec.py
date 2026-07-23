import math
from typing import Callable, Optional

def locate_threshold(mean_fn: Callable[[int, float], float], n: int,
                     p_lo: float, p_hi: float,
                     grid: int = 2000) -> Optional[float]:
    """Return the p where mean_fn(n, p) crosses 1 (the threshold scale)."""
    log_lo, log_hi = math.log(p_lo), math.log(p_hi)
    prev_p = p_lo
    prev_small = mean_fn(n, p_lo) < 1.0
    for k in range(1, grid + 1):
        p = math.exp(log_lo + (log_hi - log_lo) * k / grid)
        mu = mean_fn(n, p)
        if prev_small and mu >= 1.0:
            return math.sqrt(prev_p * p)  # geometric midpoint
        prev_small = mu < 1.0
        prev_p = p
    return None
