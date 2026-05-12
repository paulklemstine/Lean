from typing import List, Tuple, Optional
import math

def bottleneck_value(observers: List[Observer], beta: float) -> Tuple[float, Observer]:
    """Algorithm 1: Compute B(β) = min_i (c_i + β * d_i).

    Args:
        observers: Nonempty list of canonical observer factors.
        beta: Non-negative trade-off parameter.

    Returns:
        Tuple of (B(β), optimal observer).

    Time complexity: O(n) where n = |observers|.
    Space complexity: O(1) beyond input.

    >>> obs = [Observer("A", 1.0, 3.0), Observer("B", 2.0, 1.0)]
    >>> val, opt = bottleneck_value(obs, 1.0)
    >>> val
    3.0
    >>> opt.name
    'B'
    """
    assert len(observers) > 0, "Observer set must be nonempty"
    assert beta >= 0, "β must be non-negative"

    best_obs = observers[0]
    best_val = best_obs.objective(beta)

    for obs in observers[1:]:
        val = obs.objective(beta)
        if val < best_val:
            best_val = val
            best_obs = obs

    return best_val, best_obs