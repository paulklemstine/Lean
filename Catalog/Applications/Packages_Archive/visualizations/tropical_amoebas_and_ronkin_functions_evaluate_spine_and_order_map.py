import math
from typing import List, Sequence, Tuple

def spine_and_order(support: List[Tuple[float, Tuple[int, ...]]], x: Sequence[float]) -> Tuple[float, Tuple[int, ...]]:
    A = [math.log(c) + sum(mk*xk for mk, xk in zip(m, x)) for c, m in support]
    k = max(range(len(A)), key=lambda i: A[i])
    return A[k], support[k][1]
