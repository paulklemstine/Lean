from __future__ import annotations
import math

def certified_width(L: float, alpha: float, eps: float) -> int:
    """Minimal width n guaranteeing uniform error <= eps (Corollary 2.1).

    By `pwLinInterp_holder_error`, sup-error <= 2L/n^alpha; solving 2L/n^alpha <= eps
    gives n >= (2L/eps)^(1/alpha).
    """
    if not (L >= 0 and alpha > 0 and eps > 0):
        raise ValueError("require L>=0, alpha>0, eps>0")
    return math.ceil((2.0 * L / eps) ** (1.0 / alpha))
