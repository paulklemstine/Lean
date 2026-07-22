from __future__ import annotations
from math import log
from typing import List

def mobius(n: int) -> int:
    """Mobius function mu(n)."""
    if n == 1:
        return 1
    result, d, m = 1, 2, n
    while d * d <= m:
        if m % d == 0:
            m //= d
            if m % d == 0:
                return 0
            result = -result
        d += 1
    if m > 1:
        result = -result
    return result

def zeta(s: float, terms: int = 200_000) -> float:
    return sum(n ** (-s) for n in range(1, terms + 1))

def prime_zeta_via_log_zeta(s: float, k_max: int = 40) -> float:
    """Reconstruct P(s) = sum_{k>=1} mu(k)/k * log zeta(k s) for s > 1
    (logarithmic Euler product + Mobius inversion)."""
    total = 0.0
    for k in range(1, k_max + 1):
        mu = mobius(k)
        if mu != 0:
            total += mu / k * log(zeta(k * s))
    return total
