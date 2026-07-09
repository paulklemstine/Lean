from typing import Sequence
import math

def inverse_stereographic(x: Sequence[float]) -> list[float]:
    """Lift x in R^n to the unit sphere in R^{n+1}."""
    a = sum(xi * xi for xi in x)
    horizontal = [2.0 * xi / (1.0 + a) for xi in x]
    vertical = (a - 1.0) / (1.0 + a)
    return horizontal + [vertical]

def chordal_distance_sq(x: Sequence[float], y: Sequence[float]) -> float:
    """Squared ambient (chordal) distance between the lifts of x and y."""
    px = inverse_stereographic(x)
    py = inverse_stereographic(y)
    return sum((a - b) ** 2 for a, b in zip(px, py))

def chordal_identity_rhs(x: Sequence[float], y: Sequence[float]) -> float:
    """4|x-y|^2 / ((1+|x|^2)(1+|y|^2))."""
    a = sum(xi * xi for xi in x)
    b = sum(yi * yi for yi in y)
    d = sum((xi - yi) ** 2 for xi, yi in zip(x, y))
    return 4.0 * d / ((1.0 + a) * (1.0 + b))

def verify_chordal_identity(x: Sequence[float], y: Sequence[float],
                            tol: float = 1e-10) -> bool:
    """Return True if the chordal metric identity holds at (x, y)."""
    return math.isclose(chordal_distance_sq(x, y),
                        chordal_identity_rhs(x, y), abs_tol=tol)
