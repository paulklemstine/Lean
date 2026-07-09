import math
from typing import Mapping


def tropical_bezout_roots(
    coeffs: Mapping[int, float],
    degree: int,
    lo: float = -1e6,
    hi: float = 1e6,
) -> list[tuple[float, int]]:
    """
    Count roots (with multiplicity) of the univariate tropical polynomial
        T(w) = min_k ( coeffs[k] + k * w ),  0 <= k <= degree.

    Each root is a breakpoint of the concave lower envelope; its multiplicity is
    the slope drop. The sum of multiplicities equals `degree` (tropical Bezout).

    Returns sorted (root, multiplicity) pairs.  O(d log d).
    """
    # Lower envelope of lines y = c_k + k * w via slope-sorted convex-hull trick.
    pts = sorted(coeffs.items())  # (slope k, intercept c_k)
    # Keep upper convex hull of (k, c_k): these slopes appear in the min-envelope.
    hull: list[tuple[int, float]] = []
    for k, c in pts:
        while len(hull) >= 2:
            (k1, c1), (k2, c2) = hull[-2], hull[-1]
            # crossing w of lines (k1,c1)&(k2,c2) vs (k2,c2)&(k,c)
            w12 = (c1 - c2) / (k2 - k1)
            w23 = (c2 - c) / (k - k2)
            if w12 >= w23:
                hull.pop()
            else:
                break
        hull.append((k, c))
    roots: list[tuple[float, int]] = []
    for (k1, c1), (k2, c2) in zip(hull, hull[1:]):
        w = (c1 - c2) / (k2 - k1)
        if lo <= w <= hi:
            roots.append((w, k2 - k1))
    return roots
