from __future__ import annotations
from typing import Dict


def dual(coeffs: Dict[int, int]) -> Dict[int, int]:
    """Spanier-Whitehead dual D: reflect the grading, T^d -> T^{-d}.

    An involution (applying it twice is the identity) that preserves the Euler
    characteristic. O(number of terms).
    """
    return {-d: a for d, a in coeffs.items() if a}
