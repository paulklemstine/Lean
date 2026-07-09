from __future__ import annotations
import math
from typing import List


def continued_fraction_terms(x: float, n_terms: int = 22) -> List[int]:
    """First partial quotients [a0; a1, ...] of x (numeric extraction)."""
    terms: List[int] = []
    v = x
    for _ in range(n_terms):
        a = math.floor(v)
        terms.append(a)
        frac = v - a
        if frac < 1e-12:
            break
        v = 1.0 / frac
    return terms


def lagrange_constant(x: float) -> float:
    """
    k(x) = liminf_n 1 / (theta_{n+1} + [0; a_n, ..., a_1]),
    where theta_{n+1} = [a_{n+1}; a_{n+2}, ...] is the (n+1)-st complete
    quotient.  Both terms are O(1), so the estimate is numerically stable.
    """
    a = continued_fraction_terms(x, 22)
    m = len(a)
    vals: List[float] = []
    for n in range(2, min(m - 4, 16)):
        theta = float(a[m - 1])
        for i in range(m - 2, n, -1):
            theta = a[i] + 1.0 / theta
        t = float(a[1])
        for k in range(2, n + 1):
            t = a[k] + 1.0 / t
        vals.append(1.0 / (theta + 1.0 / t))
    return min(vals)
