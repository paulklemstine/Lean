from __future__ import annotations
import math

def necessary_depth(mu: float, alpha: float, v_energy: float, eps: float) -> int:
    """Exact minimal depth k with sigma^k * <v,v> < eps, sigma = (1-alpha*mu)^2
    (inversion of Theorem 4.2). Requires 0 < sigma < 1."""
    sigma = (1.0 - alpha * mu) ** 2
    if not (0.0 < sigma < 1.0):
        raise ValueError("step alpha must satisfy 0 < (1-alpha*mu)^2 < 1")
    k = math.ceil(math.log(v_energy / eps) / math.log(1.0 / sigma))
    return max(k, 0)
