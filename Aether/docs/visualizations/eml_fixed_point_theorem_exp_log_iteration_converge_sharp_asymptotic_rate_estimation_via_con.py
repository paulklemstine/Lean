from __future__ import annotations
import math
from typing import List, Tuple


def estimate_sharp_rate(a: float, b: float, c: float, x0: float,
                        n_steps: int = 60, tol: float = 1e-15
                        ) -> Tuple[float, float, List[float]]:
    def f(x: float) -> float:
        return math.exp(a) * math.log(b * x + c)

    x = x0
    for _ in range(100_000):
        nx = f(x)
        if abs(nx - x) < tol:
            x = nx
            break
        x = nx
    xstar = x
    local_rate = abs(math.exp(a) * b / (b * xstar + c))

    xs = [x0]
    for _ in range(n_steps):
        xs.append(f(xs[-1]))

    ratios: List[float] = []
    for k in range(1, len(xs)):
        denom = abs(xs[k - 1] - xstar)
        if denom < 1e-12:
            break
        ratios.append(abs(xs[k] - xstar) / denom)
    return xstar, local_rate, ratios
