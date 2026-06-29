from math import sqrt
from typing import Optional, Sequence, Tuple

Point = Tuple[float, ...]

def euclidean(a: Point, b: Point) -> float:
    return sqrt(sum((x - y) ** 2 for x, y in zip(a, b)))

def cech_vertex_center(face: Sequence[Point], eps: float) -> Optional[Point]:
    """Reverse direction: a vertex covering the whole face within eps."""
    for c in face:
        if all(euclidean(x, c) <= eps for x in face):
            return c
    return None

def forward_certificate(face: Sequence[Point], center: Point,
                        eps: float) -> bool:
    """Cech(eps) -> VR(2 eps): triangle inequality gives all pairs <= 2 eps."""
    if not all(euclidean(x, center) <= eps + 1e-12 for x in face):
        return False
    return all(euclidean(x, y) <= 2 * eps + 1e-12
               for x in face for y in face)
