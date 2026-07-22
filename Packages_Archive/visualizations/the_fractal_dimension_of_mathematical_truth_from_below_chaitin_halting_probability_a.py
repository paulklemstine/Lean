from __future__ import annotations
from typing import Callable, List

def omega_from_below(
        halts_within: Callable[[int, int], bool],
        num_programs: int,
        length: Callable[[int], int],
        budgets: List[int]) -> List[float]:
    """Ascending rational lower bounds for a prefix-machine halting probability
    Omega = sum over halting p of 2^-|p|. Dovetailing over larger step budgets
    only ever adds mass, so the sequence is non-decreasing (from-below)."""
    out: List[float] = []
    for b in budgets:
        out.append(sum(2.0 ** (-length(p))
                       for p in range(num_programs) if halts_within(p, b)))
    return out
