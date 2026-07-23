from typing import List
import math

def stable_softmax(w: List[float]) -> List[float]:
    """Overflow-safe softmax; output is a partition of unity."""
    m: float = max(w)                       # shift invariance
    exps: List[float] = [math.exp(x - m) for x in w]
    z: float = sum(exps)
    return [e / z for e in exps]
