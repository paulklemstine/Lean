import math
from typing import Tuple

def classify(b: int, k: int) -> Tuple[str, float]:
    if k == b:
        return ('trivial', 1.0)
    if k == 1:
        return ('deterministic', 0.0)
    return ('subcritical', math.log(k) / math.log(b))
