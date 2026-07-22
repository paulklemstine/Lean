from __future__ import annotations
import math


def interval_nested(eps: float, C: float, q: float) -> bool:
    """True iff [1 - q^{-eps}, 1) is contained in (1 - C/log q, 1)."""
    return q ** (-eps) <= C / math.log(q)
