import cmath
import math
from typing import Callable


def jones_trefoil(t: complex) -> complex:
    return -t**-4 + t**-3 + t**-1


def jones_figure_eight(t: complex) -> complex:
    return t**-2 - t**-1 + 1.0 - t + t**2


def information_content(jones: Callable[[complex], complex]) -> float:
    """I = log|V(e^{i pi/3})|, the log quantum dimension of the thought-knot."""
    t = cmath.exp(1j * math.pi / 3)
    modulus = abs(jones(t))
    return math.log(modulus) if modulus > 0 else float("-inf")
