from __future__ import annotations
import math
from typing import Callable, List, Sequence

Point = Sequence[float]
Metric = Callable[[Point, Point], float]


def euclidean(x: Point, y: Point) -> float:
    return math.sqrt(sum((a - b) ** 2 for a, b in zip(x, y)))


def packing_upper_bound(side: float, eps: float, dim: int) -> int:
    """Cover a box of given side with cells of diameter < eps and count them.

    By the packing bound, an eps-separated catalog holds at most one point per cell,
    so this cell count upper-bounds the number of mutually eps-novel results.
    """
    cells_per_axis = max(1, math.ceil(side / (eps / math.sqrt(dim))))
    return cells_per_axis ** dim


def greedy_separated(points: Sequence[Point], eps: float,
                     dist: Metric = euclidean) -> List[Point]:
    """Greedily build a maximal eps-separated catalog (a realizable lower witness)."""
    chosen: List[Point] = []
    for p in points:
        if all(dist(p, c) >= eps for c in chosen):
            chosen.append(p)
    return chosen
