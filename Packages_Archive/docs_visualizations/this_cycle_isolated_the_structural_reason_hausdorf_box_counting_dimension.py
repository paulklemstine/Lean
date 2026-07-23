from __future__ import annotations
import math
from typing import Sequence


def box_counting_dimension(points: Sequence[float],
                           scales: Sequence[float]) -> float:
    """Estimate the box-counting (Minkowski) dimension of a 1-D point set.

    For each gauge eps in `scales`, count the number N(eps) of distinct
    length-eps boxes that contain a point, then return the least-squares slope
    of log N(eps) against log(1/eps).  Bi-Lipschitz images of the same set
    yield the same slope (up to boundary effects), illustrating the invariance
    theorem dimH(f(s)) = dimH(s).
    """
    xs = [math.log(1.0 / s) for s in scales]
    ys = [math.log(len({math.floor(p / s) for p in points})) for s in scales]
    n = len(xs)
    mx = sum(xs) / n
    my = sum(ys) / n
    num = sum((x - mx) * (y - my) for x, y in zip(xs, ys))
    den = sum((x - mx) ** 2 for x in xs)
    return num / den
