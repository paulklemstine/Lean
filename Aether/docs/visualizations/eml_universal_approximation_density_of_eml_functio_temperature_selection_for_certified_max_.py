from __future__ import annotations
import math
from typing import Sequence


def select_temperature(num_inputs: int, target_eps: float) -> float:
    """Smallest temperature c guaranteeing |scaled_lse - max| <= target_eps.

    By the bound |(1/c) log sum_i e^{c x_i} - max_i x_i| <= log(m)/c, choosing
    c = log(m)/eps certifies error <= eps for any inputs.
    """
    assert num_inputs >= 2 and target_eps > 0.0
    return math.log(num_inputs) / target_eps


def soft_max_certified(xs: Sequence[float], target_eps: float) -> float:
    """Soft maximum of xs guaranteed within target_eps of the true maximum."""
    c: float = select_temperature(len(xs), target_eps)
    m: float = max(xs)
    return m + math.log(sum(math.exp(c * (x - m)) for x in xs)) / c
