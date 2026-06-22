from __future__ import annotations
from math import exp
from typing import List, Tuple


def lower_envelope_breakpoints(
    lines: List[Tuple[float, float]]
) -> List[Tuple[float, float]]:
    """Critical bond dimensions from the lower envelope of cut lines (a_i, c_i).

    Each line is a_i + c_i * t in t = log D. Sort by slope, maintain the lower
    envelope via a convex-hull-trick sweep, and emit (t_c, D_c=exp(t_c)) at each
    active breakpoint. Complexity O(m log m).
    """
    pts = sorted(set(lines), key=lambda ac: (ac[1], ac[0]))
    hull: List[Tuple[float, float]] = []

    def x_cross(l1: Tuple[float, float], l2: Tuple[float, float]) -> float:
        (a1, c1), (a2, c2) = l1, l2
        return (a1 - a2) / (c2 - c1)

    for a, c in pts:
        while len(hull) >= 1 and hull[-1][1] == c:
            if hull[-1][0] <= a:
                a = None  # dominated at this slope
                break
            hull.pop()
        if a is None:
            continue
        while len(hull) >= 2 and \
                x_cross(hull[-2], hull[-1]) >= x_cross(hull[-1], (a, c)):
            hull.pop()
        hull.append((a, c))

    out: List[Tuple[float, float]] = []
    for i in range(1, len(hull)):
        t_c = x_cross(hull[i - 1], hull[i])
        out.append((t_c, exp(t_c)))
    return out
