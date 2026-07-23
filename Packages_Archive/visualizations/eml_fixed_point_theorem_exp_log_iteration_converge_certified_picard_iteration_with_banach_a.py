from __future__ import annotations
import math
from typing import List, Tuple


def certified_picard(a: float, b: float, c: float, x0: float,
                     rho: float, n_steps: int) -> List[Tuple[int, float, float]]:
    if not (0.0 <= rho < 1.0):
        raise ValueError("rho must lie in [0, 1)")

    def f(x: float) -> float:
        arg = b * x + c
        if arg <= 0.0:
            raise ValueError("log argument b*x+c must be positive")
        return math.exp(a) * math.log(arg)

    xs: List[float] = [x0]
    for _ in range(n_steps):
        xs.append(f(xs[-1]))
    first_step = abs(xs[1] - xs[0])
    return [(n, xs[n], first_step * rho ** n / (1.0 - rho))
            for n in range(len(xs))]
