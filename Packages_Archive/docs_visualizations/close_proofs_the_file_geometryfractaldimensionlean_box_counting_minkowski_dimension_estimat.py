from __future__ import annotations
import math
from typing import Iterable, List, Sequence, Tuple

Point = Tuple[float, float]

def box_count(points: Iterable[Point], eps: float) -> int:
    """Count the grid cells of side `eps` that contain at least one point."""
    occupied: set = set()
    for x, y in points:
        occupied.add((math.floor(x / eps), math.floor(y / eps)))
    return len(occupied)

def box_dimension(points: Sequence[Point], scales: Sequence[float]) -> float:
    """Estimate the box-counting (Minkowski) dimension as the least-squares slope
    of log N(eps) against log(1/eps)."""
    xs: List[float] = []
    ys: List[float] = []
    for eps in scales:
        n = box_count(points, eps)
        if n > 0:
            xs.append(math.log(1.0 / eps))
            ys.append(math.log(n))
    m = len(xs)
    mx = sum(xs) / m
    my = sum(ys) / m
    num = sum((x - mx) * (y - my) for x, y in zip(xs, ys))
    den = sum((x - mx) ** 2 for x in xs)
    return num / den
