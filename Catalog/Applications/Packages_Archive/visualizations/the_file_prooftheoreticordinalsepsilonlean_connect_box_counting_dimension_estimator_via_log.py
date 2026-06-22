import math
from typing import List, Sequence

def box_counting_dimension(points: Sequence[float],
                           scales: Sequence[int] = (2,4,8,16,32,64,128,256)) -> float:
    """Estimate Hausdorff dimension of a sampled subset of [0,1] as the
    log-log slope of N(eps) (number of occupied boxes) against 1/eps."""
    xs: List[float] = []
    ys: List[float] = []
    for n in scales:
        occupied = set()
        for p in points:
            occupied.add(min(int(p * n), n - 1))
        xs.append(math.log(n))
        ys.append(math.log(len(occupied)))
    k = len(xs)
    mx = sum(xs) / k
    my = sum(ys) / k
    num = sum((x - mx) * (y - my) for x, y in zip(xs, ys))
    den = sum((x - mx) ** 2 for x in xs)
    return num / den
