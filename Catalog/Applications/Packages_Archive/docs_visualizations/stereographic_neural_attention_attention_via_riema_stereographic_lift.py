from typing import List, Sequence, Tuple

Vector = Sequence[float]

def stereographic_lift(x: Vector) -> Tuple[List[float], float]:
    """Lift x onto the unit sphere; returns (horizontal_part, height)."""
    t: float = sum(xi * xi for xi in x)
    scale: float = 2.0 / (1.0 + t)
    horizontal: List[float] = [scale * xi for xi in x]
    height: float = (t - 1.0) / (t + 1.0)
    return horizontal, height
