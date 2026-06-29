import math
from typing import Tuple

def compose(b1: int, k1: int, d1: int,
            b2: int, k2: int, d2: int) -> Tuple[int, int, float]:
    total = b1 ** d1 * b2 ** d2
    succ = k1 ** d1 * k2 ** d2
    assert succ <= total
    entropy = d1 * math.log(k1) + d2 * math.log(k2)
    return (total, succ, entropy)
