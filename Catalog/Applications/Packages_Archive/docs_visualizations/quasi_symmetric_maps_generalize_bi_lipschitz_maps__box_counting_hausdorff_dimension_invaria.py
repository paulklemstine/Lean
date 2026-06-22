import math
from typing import Sequence, List

def box_count_dimension_1d(points: Sequence[float], scales: Sequence[float]) -> float:
    xs: List[float] = []
    ys: List[float] = []
    for eps in scales:
        occupied = {math.floor(p / eps) for p in points}
        if len(occupied) <= 0:
            continue
        xs.append(math.log(1.0 / eps))
        ys.append(math.log(len(occupied)))
    m = len(xs)
    sx, sy = sum(xs), sum(ys)
    sxx = sum(x * x for x in xs)
    sxy = sum(x * y for x, y in zip(xs, ys))
    denom = m * sxx - sx * sx
    return (m * sxy - sx * sy) / denom if denom != 0 else float('nan')