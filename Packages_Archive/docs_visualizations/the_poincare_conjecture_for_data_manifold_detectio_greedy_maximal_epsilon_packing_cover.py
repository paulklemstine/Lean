from __future__ import annotations
from math import dist
from typing import Sequence
Point = tuple[float, ...]
def maximal_packing_cover(points: Sequence[Point], epsilon: float) -> list[int]:
    if epsilon < 0: raise ValueError("epsilon must be nonnegative")
    selected: list[int] = []
    for i,p in enumerate(points):
        if all(dist(p,points[j]) > epsilon for j in selected): selected.append(i)
    return selected
