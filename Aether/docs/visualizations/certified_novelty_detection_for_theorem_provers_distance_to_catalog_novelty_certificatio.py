from __future__ import annotations
import math
from typing import Callable, Sequence

Point = Sequence[float]
Metric = Callable[[Point, Point], float]


def euclidean(x: Point, y: Point) -> float:
    return math.sqrt(sum((a - b) ** 2 for a, b in zip(x, y)))


def certify_novelty(catalog: Sequence[Point], x: Point, eps: float,
                    dist: Metric = euclidean) -> tuple[bool, float, Point]:
    """Compute novelty(C, x), the nearest entry, and whether an eps-certificate holds.

    Returns (certified, novelty_value, nearest_entry). A certificate at level eps
    holds iff eps > 0 and eps <= novelty(C, x); by cert_separation this guarantees
    eps <= dist(x, c) for every c in C.
    """
    if not catalog:
        raise ValueError("empty catalog has undefined novelty")
    nearest_entry = catalog[0]
    best = dist(x, nearest_entry)
    for c in catalog[1:]:
        d = dist(x, c)
        if d < best:
            best, nearest_entry = d, c
    certified = eps > 0.0 and eps <= best
    return certified, best, nearest_entry
