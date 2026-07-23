from __future__ import annotations
from typing import List, Tuple

def supermultiplicative_certificate(
    Wc: List[int], Wd: List[int], Wcd: List[int], s: int, r: int
) -> Tuple[int, int, int]:
    """Certify the tropical bound wcount(C,s)*wcount(D,r) <= wcount(C(+)D,s+r)
    and return (lower_bound, actual, gap).

    lower_bound = Wc[s] * Wd[r]   (rectangle {wt<=s} x {wt<=r})
    actual      = Wcd[s+r]        (simplex {wt(a)+wt(b) <= s+r})
    gap         = actual - lower_bound   (cross-strata census, >= 0)

    The assertion encodes wcount_append_ge; a positive gap certifies strict
    supermultiplicativity (e.g. Hamming (+) Hamming at s=r=4 gives 225 < 227).

    Complexity: O(1) given the precomputed CDFs.
    """
    lower = Wc[s] * Wd[r]
    actual = Wcd[s + r]
    gap = actual - lower
    assert lower <= actual, "supermultiplicative bound violated"
    return lower, actual, gap
