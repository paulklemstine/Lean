from __future__ import annotations
import math, bisect, random
from typing import Sequence, List

def sample_discrete_gaussian(s: float, pts: Sequence[float]) -> float:
    """Sample from the discrete Gaussian D_{pts,s} by inverse CDF."""
    weights: List[float] = [math.exp(-math.pi * x * x / (s * s)) for x in pts]
    Z: float = sum(weights)
    assert Z > 0.0, 'support must be nonempty'
    cdf: List[float] = []
    acc: float = 0.0
    for w in weights:
        acc += w / Z
        cdf.append(acc)
    u: float = random.random()
    idx: int = bisect.bisect_left(cdf, u)
    return pts[min(idx, len(pts) - 1)]
