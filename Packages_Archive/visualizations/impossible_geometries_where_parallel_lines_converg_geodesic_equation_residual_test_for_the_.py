from __future__ import annotations
import math
from typing import Callable, Tuple

def geodesic_residual(
    x: Callable[[float], float],
    y: Callable[[float], float],
    t: float,
    h: float = 1e-4,
) -> Tuple[float, float]:
    """Residuals of the split-metric geodesic equations at parameter t.

    A curve t -> (x(t), y(t)) is a geodesic iff both returned residuals vanish
    for every t. Christoffel symbols used:
        G1_12 = -tanh(y),  G1_22 = -cosh(x) sinh(x) cosh^2(y),
        G2_11 = sech^2(y) tanh(y) / cosh^2(x),  G2_12 = tanh(x).
    Complexity: O(1) per query. Derivatives via centered finite differences.
    """
    d1: Callable[[Callable[[float], float], float], float] = (
        lambda f, s: (f(s + h) - f(s - h)) / (2 * h)
    )
    d2: Callable[[Callable[[float], float], float], float] = (
        lambda f, s: (f(s + h) - 2 * f(s) + f(s - h)) / (h * h)
    )
    xt, yt = x(t), y(t)
    xd, yd = d1(x, t), d1(y, t)
    xdd, ydd = d2(x, t), d2(y, t)
    sech2 = 1.0 / math.cosh(yt) ** 2
    chr1_12 = -math.tanh(yt)
    chr1_22 = -math.cosh(xt) * math.sinh(xt) * math.cosh(yt) ** 2
    chr2_11 = sech2 * math.tanh(yt) / math.cosh(xt) ** 2
    chr2_12 = math.tanh(xt)
    res1 = xdd + 2 * chr1_12 * xd * yd + chr1_22 * yd ** 2
    res2 = ydd + chr2_11 * xd ** 2 + 2 * chr2_12 * xd * yd
    return res1, res2
