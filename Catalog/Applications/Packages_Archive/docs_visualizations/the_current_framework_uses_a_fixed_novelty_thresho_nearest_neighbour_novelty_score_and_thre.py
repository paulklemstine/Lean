from __future__ import annotations
import math
from typing import Callable, Sequence, Tuple

Point = Tuple[float, ...]
Metric = Callable[[Point, Point], float]


def euclidean(a: Point, b: Point) -> float:
    return math.sqrt(sum((p - q) ** 2 for p, q in zip(a, b)))


def novelty_certificate(
    corpus: Sequence[Point],
    x: Point,
    eps: float,
    dist: Metric = euclidean,
) -> Tuple[float, bool]:
    """Return (novelty_score, is_certified) for candidate x vs corpus."""
    if not corpus:
        return (math.inf, True)
    score = min(dist(x, s) for s in corpus)
    return (score, score >= eps)
