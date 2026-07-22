from typing import Sequence

def similarity_dimension(ratios: Sequence[float], tol: float = 1e-14) -> float:
    """Unique D >= 0 solving sum_i ratios[i]**D = 1 via monotone bisection.
    For an IFS satisfying the open set condition this equals dimH of the attractor."""
    assert all(0.0 < c < 1.0 for c in ratios), "ratios must lie in (0,1)"
    def moran(d: float) -> float:
        return sum(c ** d for c in ratios) - 1.0
    lo, hi = 0.0, 1.0
    while moran(hi) > 0.0:
        hi *= 2.0
    for _ in range(200):
        mid = 0.5 * (lo + hi)
        if moran(mid) > 0.0:
            lo = mid
        else:
            hi = mid
        if hi - lo < tol:
            break
    return 0.5 * (lo + hi)
