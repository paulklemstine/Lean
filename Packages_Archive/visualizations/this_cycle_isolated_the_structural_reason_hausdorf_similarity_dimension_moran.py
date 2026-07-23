from __future__ import annotations
from typing import Sequence


def similarity_dimension(ratios: Sequence[float],
                         tol: float = 1e-12) -> float:
    """Solve the Moran equation sum_i r_i**d = 1 for the similarity dimension d.

    For a self-similar set built from contractions with ratios r_i (each in
    (0,1)) satisfying the open set condition, the Hausdorff dimension equals the
    unique d with sum_i r_i**d = 1.  Scale invariance (dimH(c.s)=dimH(s)) is
    exactly what licenses turning the geometric self-similarity into this scalar
    equation.  Solved by bisection since the left side is strictly decreasing
    in d.  For the middle-thirds Cantor set ratios=[1/3,1/3] -> log2/log3.
    """
    def f(d: float) -> float:
        return sum(r ** d for r in ratios) - 1.0

    lo, hi = 0.0, 1.0
    while f(hi) > 0.0:
        hi *= 2.0
    while hi - lo > tol:
        mid = 0.5 * (lo + hi)
        if f(mid) > 0.0:
            lo = mid
        else:
            hi = mid
    return 0.5 * (lo + hi)
