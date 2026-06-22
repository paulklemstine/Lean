from __future__ import annotations
from typing import Dict, List, Optional, Tuple

def odd_part(x: int) -> int:
    """oddPart(x) = x / 2^{v_2(x)}."""
    while x % 2 == 0:
        x //= 2
    return x

def two_adic_val(x: int) -> int:
    v = 0
    while x % 2 == 0 and x > 0:
        x //= 2; v += 1
    return v

def divisibility_pair(subset: List[int]) -> Optional[Tuple[int, int]]:
    """Return (a, b), a | b, from any (n+1)-subset of [1, 2n] in O(|subset|)."""
    seen: Dict[int, int] = {}
    for x in subset:
        q = odd_part(x)
        if q in seen:
            y = seen[q]
            return (y, x) if two_adic_val(y) <= two_adic_val(x) else (x, y)
        seen[q] = x
    return None
