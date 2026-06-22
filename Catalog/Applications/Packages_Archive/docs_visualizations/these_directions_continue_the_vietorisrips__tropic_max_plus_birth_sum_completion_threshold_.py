from itertools import combinations
from math import sqrt
from typing import Callable, Sequence, Tuple

Point = Tuple[float, ...]
Metric = Callable[[Point, Point], float]


def euclidean(x: Point, y: Point) -> float:
    return sqrt(sum((a - b) ** 2 for a, b in zip(x, y)))


def trop_birth_sum(points: Sequence[Point], dist: Metric = euclidean) -> float:
    """Max-plus birth sum = diameter = least completion scale.

    One O(n^2) tropical fold: tropical addition is `max`, tropical zero is -inf.
    By the Diameter Form theorem the returned value D satisfies
        VR(eps) = full complex  <=>  eps >= D.
    """
    best: float = float("-inf")          # tropical additive identity
    for p, q in combinations(points, 2):
        best = max(best, dist(p, q))      # tropical (+) = max
    return best
