from __future__ import annotations
from fractions import Fraction


def orbit_is_dense(alpha: Fraction | float, steps: int, tol: float
                   ) -> tuple[bool, float, int]:
    """Decide (numerically) whether the phase-gate orbit {n*alpha mod 1} is
    dense on the circle, illustrating the proved dichotomy
        orbit dense  <=>  alpha irrational.

    Returns (looks_dense, min_gap, distinct_points).

    A Fraction input is treated as an exact rational (finite order); a float is
    treated as a generic real sample. Density is detected when the largest gap
    between consecutive sorted orbit points falls below `tol`.
    """
    if isinstance(alpha, Fraction):
        q = alpha.limit_denominator(10 ** 9).denominator
        pts = sorted({(n * alpha) % 1 for n in range(q)})
        distinct = len(pts)
        max_gap = max(
            [float(pts[i + 1] - pts[i]) for i in range(len(pts) - 1)]
            + [float(1 - pts[-1] + pts[0])]
        )
        return (max_gap < tol, max_gap, distinct)

    pts = sorted({round((n * alpha) % 1.0, 12) for n in range(steps)})
    gaps = [pts[i + 1] - pts[i] for i in range(len(pts) - 1)]
    gaps.append(1.0 - pts[-1] + pts[0])
    max_gap = max(gaps)
    return (max_gap < tol, max_gap, len(pts))
