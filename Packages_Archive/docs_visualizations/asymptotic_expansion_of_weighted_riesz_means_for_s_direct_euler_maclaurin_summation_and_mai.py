from __future__ import annotations
import math


def direct_sum(n_max: int, p: float, k: int) -> tuple[float, float, float]:
    """Exact sum_{n<N} n^p (log n)^k and its main-term ratio."""
    total: float = 0.0
    for n in range(1, n_max):
        total += (n ** p) * (math.log(n) ** k) if n >= 2 else 0.0
    main: float = (n_max ** (p + 1)) * (math.log(n_max) ** k) / (p + 1)
    return total, main, total / main
