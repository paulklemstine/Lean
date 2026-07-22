from __future__ import annotations
from fractions import Fraction

def free_count(period: int, free: set[int], depth: int) -> int:
    if period < 1 or depth < 0 or any(r < 0 or r >= period for r in free):
        raise ValueError("invalid periodic profile")
    blocks, remainder = divmod(depth, period)
    return blocks * len(free) + sum(r < remainder for r in free)

def estimate(period: int, free: set[int], depth: int) -> Fraction:
    if depth < 1:
        raise ValueError("depth must be positive")
    return Fraction(free_count(period, free, depth), depth)
