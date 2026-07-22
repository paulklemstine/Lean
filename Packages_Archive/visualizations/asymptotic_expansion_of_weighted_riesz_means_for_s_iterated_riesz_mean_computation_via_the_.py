from __future__ import annotations
import math


def iterated_mean(n_max: int, p: float, r: int) -> tuple[float, float, float]:
    """r-fold nested power mean (r summation signs) and its main-term ratio."""
    a: list[float] = [float(n) ** p for n in range(n_max)]
    for _ in range(r):
        b: list[float] = [0.0] * n_max
        for n in range(1, n_max):
            b[n] = b[n - 1] + a[n - 1]
        a = b
    main: float = (n_max ** (p + r)) * math.gamma(p + 1) / math.gamma(p + r + 1)
    return a[-1], main, a[-1] / main
