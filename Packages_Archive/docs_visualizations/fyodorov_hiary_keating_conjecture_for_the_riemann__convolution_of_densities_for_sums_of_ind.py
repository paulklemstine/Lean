import math
from typing import Callable

def gumbel_pdf(x: float) -> float:
    """Standard Gumbel density g(x) = exp(-x - exp(-x))."""
    return math.exp(-x - math.exp(-x))

def convolution_density(
    f: Callable[[float], float],
    g: Callable[[float], float],
    x: float,
    lo: float = -40.0,
    hi: float = 40.0,
    steps: int = 20000,
) -> float:
    """Density of the sum of two independent variables: (f * g)(x).

    Computes the convolution integral  \\int f(s) g(x - s) ds  by the
    trapezoidal rule. With f = g = gumbel_pdf this yields the density of the
    FHK limiting law (sum of two independent Gumbel variables).
    """
    h = (hi - lo) / steps
    total = 0.5 * (f(lo) * g(x - lo) + f(hi) * g(x - hi))
    for i in range(1, steps):
        s = lo + i * h
        total += f(s) * g(x - s)
    return total * h
