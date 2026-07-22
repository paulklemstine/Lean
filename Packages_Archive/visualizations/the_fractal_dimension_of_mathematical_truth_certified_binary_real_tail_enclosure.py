from __future__ import annotations
from fractions import Fraction
from typing import Sequence

def certified_binary_interval(prefix: Sequence[int]) -> tuple[Fraction, Fraction]:
    if any(bit not in (0, 1) for bit in prefix): raise ValueError("binary prefix required")
    lower = sum((Fraction(bit, 2 ** (i + 1)) for i, bit in enumerate(prefix)), Fraction())
    return lower, lower + Fraction(1, 2 ** len(prefix))
