from __future__ import annotations
from typing import Callable

def bsearch_threshold(p: Callable[[int], bool], lo: int, hi: int) -> int:
    """Locate the boundary index r in (lo, hi] where the Boolean predicate p
    flips from False to True.

    Precondition (loop invariant): p(lo) == False and p(hi) == True, lo < hi.
    Postcondition: p(r-1) == False and p(r) == True, lo < r <= hi.
    Worst-case predicate evaluations: ceil(log2(hi - lo)).
    No monotonicity of p is required for correctness.
    """
    while lo + 1 < hi:
        mid = (lo + hi) // 2          # lo < mid < hi, so the gap strictly shrinks
        if p(mid):                    # invariant preserved: keep an on-end
            hi = mid
        else:                         # invariant preserved: keep an off-end
            lo = mid
    return hi
