from __future__ import annotations
from typing import Dict


def suspend(coeffs: Dict[int, int], m: int) -> Dict[int, int]:
    """Apply suspension (m > 0) or desuspension (m < 0) |m| times.

    Shifts every dimension by m: T^d -> T^{d+m}. The Euler characteristic of the
    result equals (-1)^m times the original, a built-in consistency check.
    O(number of terms).
    """
    return {d + m: a for d, a in coeffs.items() if a}
