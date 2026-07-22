from fractions import Fraction
from typing import List, Tuple

Interval = Tuple[Fraction, Fraction]
IntervalSet = List[Interval]


def canonicalize(intervals: List[Interval]) -> IntervalSet:
    """Merge overlapping/touching closed intervals into disjoint canonical form."""
    cleaned: List[Interval] = [(lo, hi) for (lo, hi) in intervals if lo <= hi]
    if not cleaned:
        return []
    cleaned.sort(key=lambda iv: (iv[0], iv[1]))
    merged: IntervalSet = [cleaned[0]]
    for lo, hi in cleaned[1:]:
        last_lo, last_hi = merged[-1]
        if lo <= last_hi:           # overlapping or touching -> fuse
            merged[-1] = (last_lo, max(last_hi, hi))
        else:
            merged.append((lo, hi))
    return merged


def volume(intervals: IntervalSet) -> Fraction:
    """Exact 1-D Lebesgue volume (total length) of a finite union of intervals."""
    return sum((hi - lo for (lo, hi) in canonicalize(intervals)), Fraction(0))
