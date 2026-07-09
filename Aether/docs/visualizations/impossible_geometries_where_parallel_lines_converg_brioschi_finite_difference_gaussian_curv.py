from __future__ import annotations
import math
from typing import Callable

def gaussian_curvature_brioschi(
    E: Callable[[float, float], float],
    G: Callable[[float, float], float],
    x: float,
    y: float,
    h: float = 1e-4,
) -> float:
    """Gaussian curvature of an orthogonal metric g = E dx^2 + G dy^2 at (x, y).

    Uses the Brioschi/do Carmo formula with centered finite differences.
    Complexity: O(1) function evaluations per query (constant number of E, G calls).
    """
    root: Callable[[float, float], float] = lambda a, b: math.sqrt(E(a, b) * G(a, b))
    term_x: Callable[[float, float], float] = (
        lambda a, b: ((G(a + h, b) - G(a - h, b)) / (2 * h)) / root(a, b)
    )
    term_y: Callable[[float, float], float] = (
        lambda a, b: ((E(a, b + h) - E(a, b - h)) / (2 * h)) / root(a, b)
    )
    d_term_x = (term_x(x + h, y) - term_x(x - h, y)) / (2 * h)
    d_term_y = (term_y(x, y + h) - term_y(x, y - h)) / (2 * h)
    return -(d_term_x + d_term_y) / (2 * root(x, y))
