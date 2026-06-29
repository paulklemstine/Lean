from __future__ import annotations
import math


def critical_density(k: int, q: int = 2) -> float:
    """First-moment density bound alpha_1 = -ln q / log(1 - ((q-1)/q)^k)."""
    return -math.log(q) / math.log(1.0 - ((q - 1) / q) ** k)


def smallest_forced_m(n: int, k: int, q: int = 2) -> int:
    """Smallest m with q^n*(1-((q-1)/q)^k)^m < 1, via monotone binarysearch."""
    frac: float = (1.0 - ((q - 1) / q) ** k)
    log_entropy: float = n * math.log(q)
    log_frac: float = math.log(frac)
    # ln E[Z] = log_entropy + m*log_frac < 0  <=>  m > -log_entropy/log_frac
    lo: int = 0
    hi: int = 1
    while log_entropy + hi * log_frac >= 0.0:
        hi *= 2
    while lo < hi:
        mid: int = (lo + hi) // 2
        if log_entropy + mid * log_frac < 0.0:
            hi = mid
        else:
            lo = mid + 1
    return lo
