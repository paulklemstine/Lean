from __future__ import annotations
import math
from typing import List

def box_count(points: List[float], eps: float) -> int:
    """Number of side-`eps` grid cells meeting the point set."""
    return len({math.floor(p / eps) for p in points})

def box_dimension(points: List[float], scales: List[float]) -> float:
    """
    Box-counting (Minkowski) dimension via the least-squares slope of
    log N(eps) against log(1/eps).  For self-similar sets this equals dimH.
    """
    xs = [math.log(1.0 / e) for e in scales]
    ys = [math.log(box_count(points, e)) for e in scales]
    n = len(xs)
    mx, my = sum(xs) / n, sum(ys) / n
    num = sum((x - mx) * (y - my) for x, y in zip(xs, ys))
    den = sum((x - mx) ** 2 for x in xs)
    return num / den
