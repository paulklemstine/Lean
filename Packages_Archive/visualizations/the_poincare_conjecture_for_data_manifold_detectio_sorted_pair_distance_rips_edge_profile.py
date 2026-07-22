from __future__ import annotations
from bisect import bisect_right
from itertools import combinations
from math import dist
from typing import Sequence
Point = tuple[float, ...]
def edge_profile(points: Sequence[Point], scales: Sequence[float]) -> list[int]:
    distances=sorted(dist(points[i],points[j]) for i,j in combinations(range(len(points)),2))
    return [bisect_right(distances,e) for e in scales]
