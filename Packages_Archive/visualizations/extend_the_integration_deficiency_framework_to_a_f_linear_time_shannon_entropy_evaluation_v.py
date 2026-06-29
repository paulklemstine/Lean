from __future__ import annotations
import math
from typing import Sequence


def surprise(x: float) -> float:
    """s(x) = -x*log(x), with s(0) = 0 built in."""
    if x <= 0.0:
        return 0.0
    return -x * math.log(x)


def entropy(p: Sequence[float]) -> float:
    """Shannon entropy H(p) = sum_x s(p_x) in nats."""
    return sum(surprise(px) for px in p)
