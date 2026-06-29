from __future__ import annotations
import math
from typing import List, Tuple

Mat3 = Tuple[Tuple[int, int, int], ...]

BB1: Mat3 = ((1, -2, 2), (2, -1, 2), (2, -2, 3))
BB2: Mat3 = ((1, 2, 2), (2, 1, 2), (2, 2, 3))
BB3: Mat3 = ((-1, 2, 2), (-2, 1, 2), (-2, 2, 3))


def apply3(a: Mat3, v: Tuple[int, int, int]) -> Tuple[int, int, int]:
    return tuple(sum(a[i][k] * v[k] for k in range(3)) for i in range(3))


def berggren_tree(depth: int) -> List[Tuple[int, int, int]]:
    """Breadth-first generation of primitive Pythagorean triples from the
    seed (3,4,5). Each triple is produced exactly once. Depth d yields
    (3^(d+1)-1)/2 triples."""
    triples: List[Tuple[int, int, int]] = []
    frontier = [(3, 4, 5)]
    for _ in range(depth + 1):
        triples.extend(frontier)
        frontier = [apply3(B, t) for t in frontier for B in (BB1, BB2, BB3)]
    return triples


def is_primitive_pythagorean(t: Tuple[int, int, int]) -> bool:
    a, b, c = t
    return a * a + b * b == c * c and math.gcd(math.gcd(a, b), c) == 1
