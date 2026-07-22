from __future__ import annotations
from typing import Dict


def euler_characteristic(coeffs: Dict[int, int]) -> int:
    """Euler characteristic of a virtual graded space X = sum_d a_d T^d.

    Returns sum_d (-1)^d a_d. Exact integer arithmetic; O(number of terms).
    """
    total = 0
    for d, a in coeffs.items():
        total += a if d % 2 == 0 else -a
    return total
