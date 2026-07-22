from __future__ import annotations
from itertools import combinations
from math import dist
from typing import Sequence
Point = tuple[float, ...]
def full_simplex_threshold(points: Sequence[Point]) -> float:
    return max((dist(points[i], points[j]) for i,j in combinations(range(len(points)),2)), default=0.0)
