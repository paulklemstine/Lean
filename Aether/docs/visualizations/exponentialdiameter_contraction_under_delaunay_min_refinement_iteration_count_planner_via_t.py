import math

def plan_rounds(D: float, lam: float, eps: float) -> int:
    """Smallest K with (1/lam)^K * D <= eps, from d_k <= (1/lam)^k * D."""
    assert lam > 1.0 and D > 0.0 and eps > 0.0
    if eps >= D:
        return 0
    return math.ceil(math.log(D / eps) / math.log(lam))
