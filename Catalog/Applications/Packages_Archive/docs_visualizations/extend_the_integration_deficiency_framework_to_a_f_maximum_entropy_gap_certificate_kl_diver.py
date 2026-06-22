from __future__ import annotations
import math
from typing import Sequence


def entropy(p: Sequence[float]) -> float:
    return sum((-px * math.log(px)) for px in p if px > 0.0)


def maxent_gap(p: Sequence[float]) -> float:
    """log n - H(p) = KL(p || uniform) >= 0; zero iff p uniform."""
    n = len(p)
    gap = math.log(n) - entropy(p)
    assert gap >= -1e-12, "maximum entropy bound violated"
    return gap
