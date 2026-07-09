from fractions import Fraction
from typing import List, Tuple

Interval = Tuple[Fraction, Fraction]
IntervalSet = List[Interval]


def minkowski_sum(a: IntervalSet, b: IntervalSet,
                  canonicalize) -> IntervalSet:
    """Minkowski sum A + B for finite unions of intervals.

    Uses distributivity A + B = union over pairs of (I_i + J_j) with
    [p,q] + [r,s] = [p+r, q+s], then canonicalizes. Complexity O(mn log(mn)).
    """
    pieces: List[Interval] = [
        (lo_a + lo_b, hi_a + hi_b)
        for (lo_a, hi_a) in a
        for (lo_b, hi_b) in b
    ]
    return canonicalize(pieces)
