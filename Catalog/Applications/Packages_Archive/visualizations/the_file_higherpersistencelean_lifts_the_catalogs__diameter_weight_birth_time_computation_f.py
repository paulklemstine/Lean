from itertools import product
from math import sqrt
from typing import Sequence, Tuple

Point = Tuple[float, ...]

def euclidean(a: Point, b: Point) -> float:
    return sqrt(sum((x - y) ** 2 for x, y in zip(a, b)))

def diam_weight(face: Sequence[Point]) -> float:
    """Birth time of `face`: max internal pairwise distance (0 if <2 pts)."""
    best = 0.0
    for x, y in product(face, repeat=2):
        d = euclidean(x, y)
        if d > best:
            best = d
    return best

def in_vr(face: Sequence[Point], eps: float) -> bool:
    """VR membership; equivalent to diam_weight(face) <= eps."""
    return diam_weight(face) <= eps
