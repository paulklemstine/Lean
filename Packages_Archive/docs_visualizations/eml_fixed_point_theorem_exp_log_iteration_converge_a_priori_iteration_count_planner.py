from __future__ import annotations
import math


def a_priori_iteration_count(rho: float, first_step: float, eps: float) -> int:
    """Smallest n with rho^n/(1-rho) * |x_1 - x_0| <= eps, from the a priori
    bound. Schedules a fixed-length loop with no runtime test."""
    if first_step == 0.0:
        return 0
    target = eps * (1.0 - rho) / first_step
    if target >= 1.0:
        return 0
    return math.ceil(math.log(target) / math.log(rho))
