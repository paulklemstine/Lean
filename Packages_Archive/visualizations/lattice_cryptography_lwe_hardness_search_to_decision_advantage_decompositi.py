import math
from typing import List, Tuple

def best_coordinate_advantage(coord_adv: List[float]) -> Tuple[int, float]:
    """Pigeonhole step of search-to-decision: some coordinate carries
    advantage >= delta/n where delta = sum(coord_adv)."""
    n = len(coord_adv)
    delta = sum(coord_adv)
    i = max(range(n), key=lambda k: coord_adv[k])
    assert coord_adv[i] >= delta / n - 1e-12
    return i, coord_adv[i]

def regev_approx_factor_bound(n: float, q: float, alpha: float) -> Tuple[float, float]:
    """gamma = n/alpha, and alpha*q >= 2*sqrt(n) implies gamma <= q*sqrt(n)/2."""
    assert alpha * q >= 2 * math.sqrt(n) - 1e-9
    return n / alpha, q * math.sqrt(n) / 2
