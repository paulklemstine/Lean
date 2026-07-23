from math import inf, sqrt
from typing import Sequence, Tuple

Point = Tuple[float, ...]


def dist(x: Point, y: Point) -> float:
    """Euclidean distance."""
    return sqrt(sum((a - b) ** 2 for a, b in zip(x, y)))


def novelty_score(reference: Sequence[Point], x: Point) -> float:
    """noveltyScore(S, x) = inf_{s in S} dist(x, s); +inf for empty S."""
    if not reference:
        return inf
    return min(dist(x, s) for s in reference)


def is_novel(eps: float, reference: Sequence[Point], x: Point) -> bool:
    """IsNovel(eps, S, x) <=> eps <= noveltyScore(S, x) (Theorem 3.4)."""
    return eps <= novelty_score(reference, x)
