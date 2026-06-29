from __future__ import annotations
import math
from dataclasses import dataclass

@dataclass
class Stage:
    b: int
    k: int
    d: int

def compose_searches(stages: list[Stage]) -> tuple[float, int]:
    """Plan a modular (multi-stage) proof.

    Returns (total_entropy, worst_case_size) where
        total_entropy   = sum_i d_i * log(k_i)        (additive entropy)
        worst_case_size = prod_i b_i ** d_i           (total space bound),
    and successful paths prod_i k_i**d_i are guaranteed <= worst_case_size.
    """
    total_entropy = sum(s.d * math.log(s.k) for s in stages)
    worst_case_size = 1
    for s in stages:
        assert s.b >= 2 and 1 <= s.k <= s.b and s.d >= 0
        worst_case_size *= s.b ** s.d
    return total_entropy, worst_case_size
