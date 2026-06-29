import math
from typing import List, Sequence


def box_counting_dimension(points: Sequence[float],
                           scales: Sequence[float]) -> float:
    """Least-squares slope of log N(eps) vs log(1/eps) for 1-D point data."""
    xs: List[float] = []
    ys: List[float] = []
    for eps in scales:
        occupied = {math.floor(p / eps) for p in points}
        xs.append(math.log(1.0 / eps))
        ys.append(math.log(len(occupied)))
    n = len(xs)
    mx = sum(xs) / n
    my = sum(ys) / n
    num = sum((x - mx) * (y - my) for x, y in zip(xs, ys))
    den = sum((x - mx) ** 2 for x in xs)
    return num / den
