from __future__ import annotations
from typing import Sequence

def verify_finite_barrier(gap: float, epsilon: float, indices: Sequence[int]) -> bool:
    if gap <= 0 or epsilon <= 0: return False
    return all(n >= 0 and n * epsilon < gap for n in indices)
