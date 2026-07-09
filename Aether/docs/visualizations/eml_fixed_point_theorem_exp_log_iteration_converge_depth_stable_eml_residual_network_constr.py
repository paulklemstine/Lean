from __future__ import annotations
import math
from typing import Callable, List


def eml_residual_stack(
    a: float, b: float, c: float,
    lo: float, hi: float, depth: int,
) -> Callable[[float], float]:
    """Build a depth-`depth` EML residual network. Each block is
    x -> x + f(clamp(lo, hi, x))  with f(x) = exp(a)*log(b*x + c).

    The clamp (metric projection) is 1-Lipschitz, so each block is
    (1+rho)-Lipschitz where rho bounds |f'| on [lo, hi], and the whole
    stack is (1+rho)^depth-Lipschitz, obeying the Bernoulli floor
    (1+rho)^depth >= 1 + depth*rho.
    """
    f: Callable[[float], float] = lambda x: math.exp(a) * math.log(b * x + c)
    clamp: Callable[[float], float] = lambda x: min(hi, max(lo, x))

    def stack(x: float) -> float:
        for _ in range(depth):
            x = x + f(clamp(x))
        return x

    return stack


def certified_depth_bounds(rho: float, K: int) -> dict:
    """Return the two-sided Lipschitz envelope of a depth-K EML residual stack:
    Bernoulli floor 1 + K*rho <= (1+rho)^K <= exp(K*rho) ceiling."""
    return {
        "bernoulli_floor": 1.0 + K * rho,
        "exact": (1.0 + rho) ** K,
        "exp_ceiling": math.exp(K * rho),
    }
