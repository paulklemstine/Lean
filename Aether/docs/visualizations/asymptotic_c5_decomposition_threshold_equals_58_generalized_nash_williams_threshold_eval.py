from __future__ import annotations
from fractions import Fraction


def nw_threshold(ell: int) -> Fraction:
    """
    Generalized Nash-Williams cycle-decomposition threshold
        delta_{C_ell} = ell / (2 ell - 2).
    For odd ell >= 3 this is the conjectured minimum-degree fraction forcing a
    C_ell-decomposition of a C_ell-divisible graph.  delta_{C_3}=3/4,
    delta_{C_5}=5/8.  The sequence is strictly decreasing to 1/2
    (nwThreshold_strictAnti).
    """
    if ell < 3:
        raise ValueError("threshold defined for cycle length ell >= 3")
    return Fraction(ell, 2 * ell - 2)


def threshold_is_strictly_decreasing(lo: int, hi: int) -> bool:
    """Empirically confirm strict monotonicity on odd lengths in [lo, hi]."""
    prev = None
    for ell in range(lo | 1, hi + 1, 2):
        t = nw_threshold(ell)
        if prev is not None and not (t < prev):
            return False
        prev = t
    return True
