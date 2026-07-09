from __future__ import annotations
import math
from fractions import Fraction
from typing import List

def sqrt_continued_fraction(d: int, terms: int) -> List[int]:
    """Periodic continued fraction expansion of sqrt(d) (d non-square)."""
    a0 = math.isqrt(d)
    if a0 * a0 == d:
        raise ValueError(f"{d} is a perfect square")
    cf, m, q, a = [a0], 0, 1, a0
    for _ in range(terms - 1):
        m = q * a - m
        q = (d - m * m) // q
        a = (a0 + m) // q
        cf.append(a)
    return cf

def convergents(cf: List[int]) -> List[Fraction]:
    """The convergents p_k/q_k -- the best (worst-case closest) approximators."""
    p_prev, p_cur, q_prev, q_cur = 1, cf[0], 0, 1
    out = [Fraction(p_cur, q_cur)]
    for a in cf[1:]:
        p_prev, p_cur = p_cur, a * p_cur + p_prev
        q_prev, q_cur = q_cur, a * q_cur + q_prev
        out.append(Fraction(p_cur, q_cur))
    return out
