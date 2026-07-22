from __future__ import annotations
from typing import Sequence

def saturated_union(left: Sequence[int], right: Sequence[int], threshold: int) -> tuple[int, ...]:
    if threshold < 0 or len(left) != len(right):
        raise ValueError("invalid threshold or profile dimensions")
    if any(x < 0 for x in (*left, *right)):
        raise ValueError("counts must be nonnegative")
    return tuple(min(a + b, threshold) for a, b in zip(left, right))
