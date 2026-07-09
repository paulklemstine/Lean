from __future__ import annotations
import math
from typing import Callable, Tuple

def eml_first_order_solver(
    coeff_name: str,
    a: float = 1.0,
) -> Tuple[Callable[[float], float], Callable[[float], float]]:
    """Solve y' = c(x) y for the three archetypal EML coefficients via the
    master construction y = exp(F) where F' = c (Theorem 1).

    coeff_name in {"log", "exp", "power"}:
      * "log":   c(x) = log x,  F(x) = x log x - x,  y(x) = exp(x log x - x)
      * "exp":   c(x) = exp x,  F(x) = exp x,        y(x) = exp(exp x)
      * "power": c(x) = a/x,    F(x) = a log x,       y(x) = x**a

    Returns (y, c): the solution and its coefficient, so that y'(x) == c(x)*y(x).
    """
    if coeff_name == "log":
        F = lambda x: x * math.log(x) - x
        c = lambda x: math.log(x)
    elif coeff_name == "exp":
        F = lambda x: math.exp(x)
        c = lambda x: math.exp(x)
    elif coeff_name == "power":
        F = lambda x: a * math.log(x)
        c = lambda x: a / x
    else:
        raise ValueError(f"unknown EML coefficient class: {coeff_name}")
    y = lambda x: math.exp(F(x))
    return y, c
