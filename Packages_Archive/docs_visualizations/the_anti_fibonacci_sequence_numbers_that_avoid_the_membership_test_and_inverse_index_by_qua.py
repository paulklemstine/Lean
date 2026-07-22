from __future__ import annotations
from math import isqrt
from typing import Optional


def anti_fib_index(m: int) -> Optional[int]:
    """Return k with A(k)=m, or None if m is not an anti-Fibonacci value."""
    if m < 1:
        return None
    d = 8 * m - 7
    r = isqrt(d)
    if r * r != d:
        return None
    if (1 + r) % 2 != 0:
        return None
    return (1 + r) // 2
