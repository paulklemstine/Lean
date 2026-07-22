from __future__ import annotations
import math
from typing import List, Tuple

def ou_moments(theta: float, sigma2: float, m0: float, v0: float,
               times: List[float]) -> List[Tuple[float, float, float]]:
    """OU marginal moments and stationary variance on a time grid.

    Returns a list of (t, m(t), v(t)) with
        m(t) = m0 * exp(-theta t),
        v(t) = v0 exp(-2 theta t) + (sigma2/2theta)(1 - exp(-2 theta t)).
    """
    v_inf: float = sigma2 / (2.0 * theta)
    out: List[Tuple[float, float, float]] = []
    for t in times:
        m: float = m0 * math.exp(-theta * t)
        decay: float = math.exp(-2.0 * theta * t)
        v: float = v0 * decay + v_inf * (1.0 - decay)
        out.append((t, m, v))
    return out
