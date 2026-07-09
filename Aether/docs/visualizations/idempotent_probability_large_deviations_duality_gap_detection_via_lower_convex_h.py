from typing import Sequence

def lower_convex_hull(points: list[tuple[float, float]]) -> list[tuple[float, float]]:
    """Lower convex hull of 2D points sorted by x (Andrew's monotone chain)."""
    pts = sorted(set(points))
    if len(pts) <= 2:
        return pts
    hull: list[tuple[float, float]] = []
    for p in pts:
        while len(hull) >= 2:
            (x1, y1), (x2, y2) = hull[-2], hull[-1]
            # cross product of (hull[-1]-hull[-2]) x (p-hull[-2])
            cross = (x2 - x1) * (p[1] - y1) - (y2 - y1) * (p[0] - x1)
            if cross <= 0:
                hull.pop()
            else:
                break
        hull.append(p)
    return hull

def duality_gaps(val: Sequence[float], rate: Sequence[float]) -> list[float]:
    """For each outcome, the gap I(x) - (lower convex envelope of (val,I)) at val(x).

    Nonzero exactly at non-convex spikes; equals the spike height above its chord.
    """
    pts = list(zip(val, rate))
    hull = lower_convex_hull(pts)
    gaps: list[float] = []
    for vx, ix in pts:
        # piecewise-linear interpolation of the hull at vx
        env = ix
        for (x1, y1), (x2, y2) in zip(hull, hull[1:]):
            if x1 <= vx <= x2 and x2 > x1:
                env = y1 + (y2 - y1) * (vx - x1) / (x2 - x1)
                break
        gaps.append(ix - env)
    return gaps
