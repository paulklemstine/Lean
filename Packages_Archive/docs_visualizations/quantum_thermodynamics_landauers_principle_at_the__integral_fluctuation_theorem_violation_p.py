from __future__ import annotations
import math
from typing import Callable, Dict, Hashable

def violation_bound_check(
    p: Dict[Hashable, float],
    w: Callable[[Hashable], float],
    alpha: float,
    delta_f: float,
    xi: float,
) -> Dict[str, float]:
    """Compare the empirical second-law violation mass with the Chernoff ceiling.

    The integral fluctuation theorem guarantees
        sum_{omega : W(omega) < DeltaF - xi} p(omega) <= exp(-alpha xi).
    Returns both sides and the (nonnegative) slack.
    """
    empirical = sum(prob for o, prob in p.items() if w(o) < delta_f - xi)
    ceiling = math.exp(-alpha * xi)
    return {
        "empirical_violation_mass": empirical,
        "chernoff_ceiling": ceiling,
        "slack": ceiling - empirical,
        "bound_holds": empirical <= ceiling + 1e-15,
    }
