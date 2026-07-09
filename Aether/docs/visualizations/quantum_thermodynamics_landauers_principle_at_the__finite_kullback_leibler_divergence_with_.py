from __future__ import annotations
import math
from typing import Sequence

def kl_landauer_cost(p: Sequence[float], q: Sequence[float],
                     k: float, T: float) -> float:
    """k*T*D(p||q); D >= 0 (Gibbs) when q has full support."""
    d: float = 0.0
    for px, qx in zip(p, q):
        if px > 0.0:
            if qx <= 0.0:
                return math.inf
            d += px * math.log(px / qx)
    return k * T * d
