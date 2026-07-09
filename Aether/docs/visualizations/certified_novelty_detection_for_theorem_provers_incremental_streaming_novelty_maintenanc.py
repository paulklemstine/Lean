from __future__ import annotations
import math
from typing import Callable, List, Sequence

Point = Sequence[float]
Metric = Callable[[Point, Point], float]


def euclidean(x: Point, y: Point) -> float:
    return math.sqrt(sum((a - b) ** 2 for a, b in zip(x, y)))


def streaming_novelties(stream: Sequence[Point], queries: Sequence[Point],
                        dist: Metric = euclidean) -> List[List[float]]:
    """Maintain novelty(C, q) for each query q as the catalog C grows online.

    Implements the incremental update law novelty(C + {a}, x) = min(dist(x, a),
    novelty(C, x)): each new catalog entry refreshes every query in O(1) per query,
    avoiding an O(|C|) rescan. Returns, for each query, the novelty after each
    insertion.
    """
    current = [math.inf] * len(queries)
    history: List[List[float]] = [[] for _ in queries]
    for a in stream:
        for i, q in enumerate(queries):
            current[i] = min(current[i], dist(q, a))
            history[i].append(current[i])
    return history
