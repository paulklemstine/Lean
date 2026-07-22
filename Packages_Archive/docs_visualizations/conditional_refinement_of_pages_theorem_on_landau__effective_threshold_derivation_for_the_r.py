from __future__ import annotations
import math


def effective_threshold(eps: float, C: float,
                        limit: int = 100_000_000, margin: int = 50) -> int:
    """Smallest Q0 with m^{-eps} log m <= C for all integer m >= Q0."""
    m = 2
    while m < limit:
        if math.log(m) / (m ** eps) <= C:
            if all(math.log(k) / (k ** eps) <= C for k in range(m, m + margin)):
                return m
        m += 1
    raise RuntimeError("threshold not found within limit")
