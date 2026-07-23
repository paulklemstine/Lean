from __future__ import annotations
import math
from typing import Callable, Tuple


def eml_operator(a: float, b: float, c: float) -> Callable[[float], float]:
    return lambda x: math.exp(a) * math.log(b * x + c)


def two_sided_bracket(a: float, b: float, c: float, lo: float, hi: float,
                      eps: float, max_iter: int = 10_000
                      ) -> Tuple[float, float, int]:
    """Return a certified bracket (L, U) with U - L <= eps containing x*.

    Requires b > 0 (operator monotone). The lower orbit from lo increases, the
    upper orbit from hi decreases; both converge to the same unique fixed point.
    """
    assert b > 0.0
    f = eml_operator(a, b, c)
    L, U = lo, hi
    for n in range(1, max_iter + 1):
        L, U = f(L), f(U)
        if U - L <= eps:
            return L, U, n
    return L, U, max_iter
