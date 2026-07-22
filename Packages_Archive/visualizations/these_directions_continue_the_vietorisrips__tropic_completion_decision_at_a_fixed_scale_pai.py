from itertools import combinations
from typing import Callable, Sequence, Tuple

Point = Tuple[float, ...]
Metric = Callable[[Point, Point], float]


def is_complete_at(points: Sequence[Point], eps: float, dist: Metric) -> bool:
    """Decide VR(eps) = full complex without constructing any simplex.

    By the Completion Threshold Theorem this is equivalent to checking that every
    pairwise distance is <= eps. Short-circuits on the first violating pair, so it
    is O(n^2) worst case and often far faster.
    """
    for p, q in combinations(points, 2):
        if dist(p, q) > eps:
            return False
    return True
