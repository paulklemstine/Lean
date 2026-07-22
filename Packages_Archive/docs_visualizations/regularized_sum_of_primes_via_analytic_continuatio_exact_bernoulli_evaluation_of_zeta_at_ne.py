from __future__ import annotations
from fractions import Fraction
from math import comb
from typing import List

def bernoulli_numbers(n: int) -> List[Fraction]:
    """Exact Bernoulli numbers B_0..B_n (convention B_1 = -1/2)."""
    b: List[Fraction] = []
    for m in range(n + 1):
        s = sum(Fraction(comb(m + 1, k)) * b[k] for k in range(m))
        b.append(Fraction(1) if m == 0 else -s / Fraction(m + 1))
    return b

def zeta_at_negative_integer(n: int) -> Fraction:
    """zeta(-n) = -B_{n+1}/(n+1) for n >= 1. Returns -1/12 for n = 1."""
    return -bernoulli_numbers(n + 1)[n + 1] / Fraction(n + 1)
