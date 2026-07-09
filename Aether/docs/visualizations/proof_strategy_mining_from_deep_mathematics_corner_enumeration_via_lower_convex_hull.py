from __future__ import annotations
from typing import List, Tuple

def tropical_corners(c: List[float]) -> List[Tuple[int, int]]:
    """Return the active monomial transitions (corners) of tropPoly_c.

    The corners of the convex piecewise-linear graph are in bijection with
    the edges of the lower convex hull of the points (i, -c[i]). We compute
    that hull by Andrew's monotone chain over i = 0..d and return consecutive
    (slope_left, slope_right) index pairs whose crossing is a genuine corner.
    Complexity: O(d log d) (here points are pre-sorted by i, so O(d)).
    """
    pts: List[Tuple[int, float]] = [(i, -c[i]) for i in range(len(c))]
    hull: List[Tuple[int, float]] = []
    for p in pts:
        while len(hull) >= 2:
            (x1, y1), (x2, y2) = hull[-2], hull[-1]
            # cross product of (hull[-1]-hull[-2]) x (p-hull[-1])
            cross = (x2 - x1) * (p[1] - y1) - (y2 - y1) * (p[0] - x1)
            if cross <= 0:
                hull.pop()
            else:
                break
        hull.append(p)
    return [(hull[k][0], hull[k + 1][0]) for k in range(len(hull) - 1)]
