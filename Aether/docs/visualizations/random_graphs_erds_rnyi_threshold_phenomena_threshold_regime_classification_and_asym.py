from __future__ import annotations
import math
from typing import Callable, Literal

def triangle_window_limit(c: float) -> float:
    """Limit of C(n,3)(c/n)^3 as n->inf, i.e. c^3/6 (tendsto_expected_triangles)."""
    return c ** 3 / 6.0

def classify_triangle_regime(
    p: Callable[[int], float], n_max: int = 10 ** 6
) -> Literal["subcritical", "critical", "supercritical"]:
    """Classify the triangle regime of a density sequence p(n) by the scaling
    of n*p(n): -> 0 (subcritical), -> const>0 (critical), -> inf (supercritical).
    Estimates the trend of n*p(n) at large n."""
    big = n_max
    small = max(2, n_max // 1000)
    lo, hi = small * p(small), big * p(big)
    if hi < lo * 0.5:
        return "subcritical"
    if hi > lo * 2.0:
        return "supercritical"
    return "critical"

def expected_triangles_at(n: int, p_n: float) -> float:
    """C(n,3) * p_n^3 evaluated exactly (drives the subcritical/supercritical
    limit theorems subcritical_triangles_vanish / supercritical_triangles_blowup)."""
    return math.comb(n, 3) * p_n ** 3

def isolated_mean_at_scale(n: int, c: float, scale: str = "giant") -> float:
    """E[#isolated] at scale p=c/n ('giant') or p=ln(n)/n ('connectivity').
    The 'giant' scale diverges (isolated_blowup_below_connectivity)."""
    p_n = c / n if scale == "giant" else math.log(n) / n
    return n * (1.0 - p_n) ** (n - 1)
