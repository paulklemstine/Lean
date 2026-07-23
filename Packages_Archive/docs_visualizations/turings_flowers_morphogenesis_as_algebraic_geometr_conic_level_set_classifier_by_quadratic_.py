from __future__ import annotations


def classify_conic(A: float, B: float, C: float) -> str:
    disc = B * B - 4.0 * A * C
    if disc < 0:
        return 'spot (bounded ellipse)'
    if abs(disc) < 1e-12:
        return 'stripe (degenerate / parallel lines)'
    return 'labyrinth (unbounded hyperbola)'


def spot_radius_bound(A: float, C: float, F: float) -> float:
    assert A > 0 and C > 0
    return F / A + F / C
