from __future__ import annotations
import math
from typing import Sequence

def neg_mul_log(x: float) -> float:
    """Real.negMulLog: x |-> -x log x, with 0*log0 = 0."""
    if x <= 0.0:
        return 0.0
    return -x * math.log(x)

def entropy(p: Sequence[float]) -> float:
    """Shannon entropy H(p) = -sum_x p(x) log p(x) in nats. O(n)."""
    return sum(neg_mul_log(px) for px in p)
