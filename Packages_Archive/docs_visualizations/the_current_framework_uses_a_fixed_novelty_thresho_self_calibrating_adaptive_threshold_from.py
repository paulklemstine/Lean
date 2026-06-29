from __future__ import annotations
import itertools
import math
from typing import Callable, Sequence, Tuple

Point = Tuple[float, ...]
Metric = Callable[[Point, Point], float]


def euclidean(a: Point, b: Point) -> float:
    return math.sqrt(sum((p - q) ** 2 for p, q in zip(a, b)))


def adaptive_threshold(corpus: Sequence[Point],
                       dist: Metric = euclidean) -> float:
    """Corpus separation sigma = min distance between distinct elements."""
    if len(corpus) < 2:
        return math.inf
    return min(dist(a, b) for a, b in itertools.combinations(corpus, 2))


def certify_adaptive(corpus: Sequence[Point], x: Point,
                     dist: Metric = euclidean) -> Tuple[float, bool]:
    sigma = adaptive_threshold(corpus, dist)
    score = min(dist(x, s) for s in corpus) if corpus else math.inf
    return (sigma, score >= sigma)
