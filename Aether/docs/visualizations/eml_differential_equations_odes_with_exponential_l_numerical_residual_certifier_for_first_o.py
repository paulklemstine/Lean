from __future__ import annotations
from typing import Callable

def verify_solution(
    y: Callable[[float], float],
    c: Callable[[float], float],
    xs: list[float],
    h: float = 1e-6,
    tol: float = 1e-5,
) -> bool:
    """Numerically certify y' = c*y at sample points via central differences.

    Computes y'(x) ~ (y(x+h) - y(x-h)) / (2h) and compares to c(x)*y(x),
    accepting when the magnitude-scaled residual is below tol. This is the
    numerical witness for Theorems 2-4.
    """
    for x in xs:
        num = (y(x + h) - y(x - h)) / (2.0 * h)
        analytic = c(x) * y(x)
        scale = max(1.0, abs(analytic))
        if abs(num - analytic) > tol * scale:
            return False
    return True
