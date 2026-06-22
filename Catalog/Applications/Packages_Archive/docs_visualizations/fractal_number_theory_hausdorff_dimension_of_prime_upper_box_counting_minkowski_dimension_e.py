from __future__ import annotations
import math

def estimate_box_dimension(points: list[float], scales: int = 12,
                           eps0: float = 0.1) -> float:
    """Estimate the upper box-counting dimension by linear regression of
    log N(eps) against log(1/eps) over a geometric ladder of scales."""
    xs: list[float] = []
    ys: list[float] = []
    eps = eps0
    for _ in range(scales):
        n = len({math.floor(x / eps) for x in points})
        xs.append(math.log(1.0 / eps))
        ys.append(math.log(n))
        eps /= 2.0
    m = len(xs)
    sx, sy = sum(xs), sum(ys)
    sxx = sum(x * x for x in xs)
    sxy = sum(x * y for x, y in zip(xs, ys))
    return (m * sxy - sx * sy) / (m * sxx - sx * sx)
