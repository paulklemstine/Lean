from __future__ import annotations
import math
from itertools import combinations
from typing import Callable, Sequence, Tuple

Point = Tuple[float, float]

def dist(p: Point, q: Point) -> float:
    return math.hypot(p[0] - q[0], p[1] - q[1])

def distortion_constants_on(
    points: Sequence[Point], f: Callable[[Point], Point]
) -> Tuple[float, float]:
    """Return (K_Lip, K_anti), the empirical set-local Lipschitz and antilipschitz
    constants of f over the sample: the extremal ratios of pairwise distances.

    K_Lip  = max_{i<j} d(f p_i, f p_j) / d(p_i, p_j)
    K_anti = max_{i<j} d(p_i, p_j)   / d(f p_i, f p_j)   (inf if a pair collapses)
    """
    k_lip = 0.0
    k_anti = 0.0
    for p, q in combinations(points, 2):
        d = dist(p, q)
        df = dist(f(p), f(q))
        if d > 0:
            k_lip = max(k_lip, df / d)
        if df == 0:
            k_anti = math.inf
        else:
            k_anti = max(k_anti, d / df)
    return k_lip, k_anti
