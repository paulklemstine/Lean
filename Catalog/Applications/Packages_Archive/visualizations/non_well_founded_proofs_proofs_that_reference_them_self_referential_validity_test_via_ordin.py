from __future__ import annotations
from typing import Callable, Tuple, Optional

def valid(unfold: Callable[[int], int], max_iter: int = 1000) -> Tuple[bool, Optional[int]]:
    """Search for a finite ordinal-height fixed point h = unfold(h)."""
    h: int = 0
    for _ in range(max_iter):
        nxt: int = unfold(h)
        if nxt == h:
            return True, h        # e.g. P=>P with unfold = lambda h: 1  -> (True, 1)
        h = nxt
    return False, None            # e.g. liar with unfold = lambda h: h+1 -> (False, None)
