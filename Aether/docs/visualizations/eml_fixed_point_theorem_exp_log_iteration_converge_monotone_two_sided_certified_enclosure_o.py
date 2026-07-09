from __future__ import annotations
import math
from typing import Callable, Tuple

def eml_enclosure(a: float, b: float, c: float, lo: float, hi: float,
                  target_width: float, max_iter: int = 10_000
                  ) -> Tuple[float, float, int]:
    """Certified enclosure of the EML fixed point x* of f(x)=exp(a)*log(b*x+c).

    Requires b > 0 (so f is monotone increasing) and that f maps [lo,hi] into
    itself with |f'| <= rho < 1 there. Iterates the two endpoints until the
    bracket [l, u] is narrower than target_width. The returned interval
    provably contains x* (theorem certified_enclosure).
    """
    assert b > 0.0, "monotone enclosure requires b > 0"
    f: Callable[[float], float] = lambda x: math.exp(a) * math.log(b * x + c)
    l, u = lo, hi
    for n in range(max_iter):
        if u - l <= target_width:
            return l, u, n
        l, u = f(l), f(u)  # lower orbit rises, upper orbit falls
    return l, u, max_iter
