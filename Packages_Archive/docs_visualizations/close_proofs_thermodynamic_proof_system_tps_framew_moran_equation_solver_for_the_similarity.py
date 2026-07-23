from typing import Sequence


def similarity_dimension(ratios: Sequence[float],
                         tol: float = 1e-12,
                         max_iter: int = 200) -> float:
    """Similarity dimension D solving the Moran equation sum_i ratios_i^D = 1."""
    if any(not (0.0 < c < 1.0) for c in ratios):
        raise ValueError("each contraction ratio must lie strictly in (0, 1)")

    def moran(d: float) -> float:
        return sum(c ** d for c in ratios) - 1.0

    lo, hi = 0.0, 1.0
    while moran(hi) > 0.0:
        hi *= 2.0
    for _ in range(max_iter):
        mid = 0.5 * (lo + hi)
        if moran(mid) > 0.0:
            lo = mid
        else:
            hi = mid
        if hi - lo < tol:
            break
    return 0.5 * (lo + hi)
