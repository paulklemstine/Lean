from __future__ import annotations
import math
from typing import Iterable, List, Sequence, Tuple

Vector = Tuple[float, ...]

def norm(v: Sequence[float]) -> float:
    return math.sqrt(sum(x * x for x in v))

def bounded_distance_decode(
    lattice_points: Iterable[Vector],
    target: Sequence[float],
    radius: float,
) -> List[Vector]:
    """Return all lattice points strictly within `radius` of `target`.
    With radius = lambda_1/2 the result has at most one element."""
    return [
        p for p in lattice_points
        if norm(tuple(a - b for a, b in zip(target, p))) < radius
    ]
