from __future__ import annotations
from math import isqrt
from typing import Optional

def value_index(m: int) -> Optional[int]:
    """Return a positive n with A(n)=m, or None."""
    if m < 1:
        return None
    d = 8 * m - 7
    r = isqrt(d)
    return (r + 1) // 2 if r * r == d and r % 2 == 1 else None
