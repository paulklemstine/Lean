import math
from typing import List, Sequence, Tuple

def fisher_form(p: Sequence[float], v: Sequence[float], w: Sequence[float]) -> float:
    return sum(vi * wi / pi for pi, vi, wi in zip(p, v, w))

def kl_div(p: Sequence[float], q: Sequence[float]) -> float:
    return sum(pi * math.log(pi / qi) for pi, qi in zip(p, q))

def verify_sandwich(p: Sequence[float], q: Sequence[float],
                    tol: float = 1e-12) -> Tuple[float, float, bool]:
    """Return (KL, Fisher=chi^2, holds) checking 0 <= KL <= g_q(p-q, p-q)."""
    d: List[float] = [pi - qi for pi, qi in zip(p, q)]
    kl = kl_div(p, q)
    fisher = fisher_form(q, d, d)
    holds = (kl >= -tol) and (kl <= fisher + tol)
    return kl, fisher, holds
