from __future__ import annotations
import math
from typing import Callable, List, Sequence, Tuple

Point = Tuple[float, ...]
Metric = Callable[[Point, Point], float]


def euclidean(a: Point, b: Point) -> float:
    return math.sqrt(sum((p - q) ** 2 for p, q in zip(a, b)))


def filtration_sweep(
    corpus: Sequence[Point],
    x: Point,
    thresholds: Sequence[float],
    dist: Metric = euclidean,
) -> Tuple[Tuple[float, float], List[bool]]:
    """Return ((birth, death), verdicts) over an increasing threshold ladder."""
    score = min(dist(x, s) for s in corpus) if corpus else math.inf
    verdicts = [d <= score for d in thresholds]
    return ((0.0, score), verdicts)
