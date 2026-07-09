from __future__ import annotations
import math
from typing import Callable, List


def bernstein_approximant(f: Callable[[float, float], float], n: int
                          ) -> Callable[[float, float], float]:
    """Build the degree-n tensor Bernstein EML approximant of f on [0,1]^2.

    The returned function is a polynomial in the coordinates, hence a member of
    the coordinate-generated EML algebra. By Stone-Weierstrass it converges
    uniformly to any continuous f as n -> infinity.
    """
    coeffs: List[List[float]] = [[f(i / n, j / n) for j in range(n + 1)]
                                 for i in range(n + 1)]

    def approx(x: float, y: float) -> float:
        total: float = 0.0
        for i in range(n + 1):
            bi = math.comb(n, i) * (x ** i) * ((1.0 - x) ** (n - i))
            for j in range(n + 1):
                bj = math.comb(n, j) * (y ** j) * ((1.0 - y) ** (n - j))
                total += coeffs[i][j] * bi * bj
        return total

    return approx
