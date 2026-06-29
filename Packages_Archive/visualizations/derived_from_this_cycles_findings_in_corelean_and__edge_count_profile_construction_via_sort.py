from __future__ import annotations
import math
from typing import Callable, List, Sequence, Tuple

Point = Tuple[float, ...]

def euclidean(x: Point, y: Point) -> float:
    return math.sqrt(sum((a - b) ** 2 for a, b in zip(x, y)))

def edge_count_profile(points: Sequence[Point],
                       scales: Sequence[float],
                       dist: Callable[[Point, Point], float] = euclidean) -> List[int]:
    """Return E(r) for each r in `scales`.

    Computes all C(n,2) pairwise distances once, sorts them, then answers each
    scale query by counting distances <= r. Complexity: O(n^2) distance work +
    O(n^2 log n) sort + O(m log n) per query (m = number of scales) via binary search.
    """
    import bisect
    ds = sorted(dist(points[i], points[j])
                for i in range(len(points)) for j in range(i + 1, len(points)))
    return [bisect.bisect_right(ds, r) for r in scales]
