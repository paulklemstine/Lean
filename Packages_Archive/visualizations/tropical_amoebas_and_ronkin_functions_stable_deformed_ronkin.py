import math
from typing import List, Sequence, Tuple

def deformed_ronkin(support: List[Tuple[float, Tuple[int, ...]]], x: Sequence[float], t: float) -> float:
    if t <= 0:
        raise ValueError('t must be positive')
    A = [math.log(c) + sum(mk*xk for mk, xk in zip(m, x)) for c, m in support]
    M = max(A)
    return M + t * math.log(sum(math.exp((a - M) / t) for a in A))
