from __future__ import annotations
import cmath, math
from typing import List

def dft(f: List[complex]) -> List[complex]:
    n = len(f)
    return [sum(f[j]*cmath.exp(-2j*math.pi*j*k/n) for j in range(n)) for k in range(n)]

def idft(fhat: List[complex]) -> List[complex]:
    n = len(fhat)
    return [sum(fhat[k]*cmath.exp(2j*math.pi*j*k/n) for k in range(n))/n for j in range(n)]

def fast_convolution(f: List[complex], g: List[complex]) -> List[complex]:
    """Cyclic convolution via the convolution theorem: transform, multiply, invert."""
    fh, gh = dft(f), dft(g)
    prod = [a*b for a, b in zip(fh, gh)]
    return idft(prod)
