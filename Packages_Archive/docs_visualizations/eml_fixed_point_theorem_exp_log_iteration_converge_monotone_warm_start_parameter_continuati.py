from __future__ import annotations
import math
from typing import Callable, List, Tuple


def eml_operator(a: float, b: float, c: float) -> Callable[[float], float]:
    return lambda x: math.exp(a) * math.log(b * x + c)


def monotone_warm_start_sweep(b: float, c: float, a_grid: List[float],
                              x_init: float, tol: float = 1e-14
                              ) -> List[Tuple[float, float]]:
    """Trace the equilibrium curve a -> x*(a) by warm-started continuation.

    Sweeps a upward. Because the previous (smaller-a) equilibrium is a
    sub-solution of the next operator (fixedPoint_le_of_a_le), the warm-started
    orbit increases monotonically to the next equilibrium - a provably correct
    and efficient continuation method.
    """
    curve: List[Tuple[float, float]] = []
    x = x_init
    for a in sorted(a_grid):
        f = eml_operator(a, b, c)
        while True:
            nx = f(x)
            if abs(nx - x) < tol:
                x = nx
                break
            x = nx
        curve.append((a, x))
    return curve
