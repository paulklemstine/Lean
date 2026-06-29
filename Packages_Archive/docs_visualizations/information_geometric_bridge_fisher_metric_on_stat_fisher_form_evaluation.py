from typing import Sequence

def fisher_form(p: Sequence[float], v: Sequence[float], w: Sequence[float]) -> float:
    """Fisher information form g_p(v, w) = sum_i v_i * w_i / p_i (p_i > 0)."""
    return sum(vi * wi / pi for pi, vi, wi in zip(p, v, w))
