from __future__ import annotations
import math
from typing import Callable

def pw_lin_interp(f: Callable[[float], float], n: int, x: float) -> float:
    """Width-n piecewise-linear EML interpolant of f on [0,1], evaluated at x.

    Implements Definition 2.3 / `pwLinInterp`:
      k = min(n-1, floor(n*x)); a = k/n; b = (k+1)/n;
      return f(a) + (f(b)-f(a))/(b-a) * (x-a).
    """
    if n < 1:
        raise ValueError("width n must be >= 1")
    k: int = min(n - 1, int(math.floor(n * x)))
    a: float = k / n
    b: float = (k + 1) / n
    return f(a) + (f(b) - f(a)) / (b - a) * (x - a)
