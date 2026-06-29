import math
from typing import Sequence, Iterable


def box_dimension(points: Sequence[Sequence[float]],
                  scales: Iterable[float] | None = None) -> float:
    """Box-counting estimate of Hausdorff dimension: slope of
    log N(eps) vs log(1/eps) over a range of scales."""
    pts = list(points)
    if scales is None:
        scales = [0.5 ** k for k in range(1, 9)]
    xs, ys = [], []
    for eps in scales:
        occupied = set()
        for p in pts:
            occupied.add(tuple(math.floor(c / eps) for c in p))
        n = len(occupied)
        if n > 0:
            xs.append(math.log(1.0 / eps))
            ys.append(math.log(n))
    m = len(xs)
    mx, my = sum(xs) / m, sum(ys) / m
    num = sum((x - mx) * (y - my) for x, y in zip(xs, ys))
    den = sum((x - mx) ** 2 for x in xs)
    return num / den if den else 0.0
