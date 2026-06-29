from __future__ import annotations
from typing import Sequence

def end_to_end_bound(step_bounds: Sequence[float], K: float) -> float:
    budget: float = sum(step_bounds)
    return K * budget

def compose_loss_factors(factors: Sequence[float]) -> float:
    # chained reductions: loss factors multiply (K2 * K1 * ...)
    product: float = 1.0
    for k in factors:
        product *= k
    return product