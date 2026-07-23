from __future__ import annotations
import math
from typing import Optional

def profile_of_beta(beta: float) -> Optional[float]:
    """Construction profile p_min(beta) = t^2 (1 - t), t = 1 - sqrt(1 - 2 beta).

    Returns None for beta > 1/2 (ill-posed regime, Thm 4.1)."""
    if beta < 0.0 or beta > 0.5:
        return None
    t: float = 1.0 - math.sqrt(1.0 - 2.0 * beta)
    return t * t * (1.0 - t)
