from typing import List, Tuple
import math

def lse_certified(w: List[float]) -> Tuple[float, float, float]:
    """Return (lse, lower=max, upper=max+log n) Maslov sandwich."""
    m: float = max(w)
    s: float = sum(math.exp(x - m) for x in w)
    value: float = m + math.log(s)
    return value, m, m + math.log(len(w))
