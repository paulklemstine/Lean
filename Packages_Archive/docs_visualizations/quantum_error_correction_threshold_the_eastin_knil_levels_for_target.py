import math

def levels_for_target(c: float, p: float, eps: float) -> int:
    q0 = c * p
    if not (0.0 <= q0 < 1.0):
        raise ValueError("requires 0 <= c*p < 1 (below threshold)")
    target = c * eps
    k = math.log(target) / math.log(q0)
    if k <= 1.0:
        return 0
    return math.ceil(math.log2(k))
