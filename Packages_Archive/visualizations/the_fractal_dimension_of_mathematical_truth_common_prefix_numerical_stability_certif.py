from __future__ import annotations
from fractions import Fraction
from typing import Sequence

def prefix_stability_bound(x: Sequence[int], y: Sequence[int]) -> tuple[int, Fraction]:
    if any(bit not in (0, 1) for bit in (*x, *y)): raise ValueError("binary data required")
    n = 0
    while n < min(len(x), len(y)) and x[n] == y[n]: n += 1
    return n, Fraction(1, 2 ** n)
