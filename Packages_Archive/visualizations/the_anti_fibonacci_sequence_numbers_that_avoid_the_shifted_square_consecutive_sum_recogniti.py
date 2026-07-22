from __future__ import annotations
from math import isqrt
from typing import Optional

def consecutive_sum_index(m: int) -> Optional[int]:
    """Return n with m=A(n)+A(n+1), or None."""
    if m < 2:
        return None
    r = isqrt(m - 2)
    return r if r * r == m - 2 else None
