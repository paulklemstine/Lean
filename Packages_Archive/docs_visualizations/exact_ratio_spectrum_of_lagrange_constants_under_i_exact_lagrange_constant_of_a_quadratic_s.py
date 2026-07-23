from __future__ import annotations
import math
from typing import List


def cf_sqrt(big_n: int) -> List[int]:
    """Exact periodic continued fraction of sqrt(big_n): [a0] + one period."""
    a0 = math.isqrt(big_n)
    if a0 * a0 == big_n:
        return [a0]
    terms = [a0]
    m, d, a = 0, 1, a0
    while a != 2 * a0:
        m = d * a - m
        d = (big_n - m * m) // d
        a = (a0 + m) // d
        terms.append(a)
    return terms


def lagrange_constant_sqrt(big_n: int) -> float:
    """Exact Lagrange constant of sqrt(big_n) via its periodic CF."""
    head = cf_sqrt(big_n)
    a0, period = head[0], head[1:]
    if not period:
        return 0.0
    a = [a0] + period * 30
    m = len(a)
    vals: List[float] = []
    L = len(period)
    for n in range(L + 2, L + 2 + 2 * L):
        theta = float(a[m - 1])
        for i in range(m - 2, n, -1):
            theta = a[i] + 1.0 / theta
        t = float(a[1])
        for k in range(2, n + 1):
            t = a[k] + 1.0 / t
        vals.append(1.0 / (theta + 1.0 / t))
    return min(vals)


def dilation_ratio_sqrt(d: int, n: int) -> float:
    """Exact k(n*sqrt(d))/k(sqrt(d)) using n*sqrt(d) = sqrt(n^2 d)."""
    return lagrange_constant_sqrt(n * n * d) / lagrange_constant_sqrt(d)
