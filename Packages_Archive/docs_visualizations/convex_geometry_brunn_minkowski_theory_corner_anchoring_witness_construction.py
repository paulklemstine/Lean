from fractions import Fraction
from typing import List, Tuple

Interval = Tuple[Fraction, Fraction]
IntervalSet = List[Interval]


def corner_anchoring_witness(a: IntervalSet, b: IntervalSet,
                             canonicalize, volume):
    """Build the corner-anchoring translates U = A + {inf B}, V = {sup A} + B.

    Returns (U, V, seam) where U and V both lie inside A + B, intersect only at
    the seam point sup(A) + inf(B), and satisfy vol(U) = vol(A), vol(V) = vol(B).
    These are the exact witnesses used in the proof of brunn_minkowski_1d.
    """
    canon_a, canon_b = canonicalize(a), canonicalize(b)
    a_max: Fraction = max(hi for (_, hi) in canon_a)   # sup A
    b_min: Fraction = min(lo for (lo, _) in canon_b)   # inf B
    U: IntervalSet = canonicalize([(lo + b_min, hi + b_min) for (lo, hi) in canon_a])
    V: IntervalSet = canonicalize([(lo + a_max, hi + a_max) for (lo, hi) in canon_b])
    seam: Fraction = a_max + b_min
    assert volume(U) == volume(canon_a)
    assert volume(V) == volume(canon_b)
    return U, V, seam
