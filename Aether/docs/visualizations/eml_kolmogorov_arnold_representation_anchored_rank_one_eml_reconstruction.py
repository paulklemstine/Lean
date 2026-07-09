import math
from typing import Callable, Tuple

def reconstruct_rank_one_eml(
    f: Callable[[float, float], float],
    x0: float,
    y0: float,
) -> Tuple[Callable[[float], float], Callable[[float], float]]:
    """For a strictly positive CrossMul target, return (psi, phi) with
    f(x, y) = exp(psi(x) + phi(y)), via the anchored slices
        psi(x) = log( f(x, y0) / f(x0, y0) ),   phi(y) = log( f(x0, y) )."""
    f00 = f(x0, y0)
    if f00 <= 0:
        raise ValueError("anchor must be strictly positive")
    def psi(x: float) -> float:
        return math.log(f(x, y0) / f00)
    def phi(y: float) -> float:
        return math.log(f(x0, y))
    return psi, phi
