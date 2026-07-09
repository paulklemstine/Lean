from __future__ import annotations
import math
from typing import Tuple

def threshold_const(k: int) -> float:
    return math.exp((math.log(k - 1) + (k - 2) * math.log(2 * (k - 1) / k)) / (k - 1))

def locate_peak(lo: int = 4, hi: int = 200) -> Tuple[int, float]:
    """Return (k*, c_{k*}) maximizing the unimodal sequence c_k by ternary search.

    Uses that the sequence is unimodal on [lo, hi]; O(log(hi-lo)) evaluations.
    """
    while hi - lo > 2:
        m1 = lo + (hi - lo) // 3
        m2 = hi - (hi - lo) // 3
        if threshold_const(m1) < threshold_const(m2):
            lo = m1 + 1
        else:
            hi = m2 - 1
    best = max(range(lo, hi + 1), key=threshold_const)
    return best, threshold_const(best)

if __name__ == '__main__':
    print(locate_peak())
