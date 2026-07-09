from dataclasses import dataclass
from typing import Tuple

@dataclass(frozen=True)
class Circle:
    rep: float

@dataclass(frozen=True)
class Torus:
    x: float
    y: float

def loop(t: float) -> Circle:
    return Circle(0.0 if abs(t - 1.0) <= 1e-12 else t)

def torus_mk(p: Tuple[float, float]) -> Torus:
    x, y = p
    return Torus(0.0 if abs(x-1.0)<=1e-12 else x, 0.0 if abs(y-1.0)<=1e-12 else y)

def to_circles(t: Torus) -> Tuple[Circle, Circle]:
    """toCircles: torus point -> (longitude, meridian) pair of circle points."""
    return (loop(t.x), loop(t.y))

def of_circles(pair: Tuple[Circle, Circle]) -> Torus:
    """ofCircles: pair of circle points -> torus point."""
    c1, c2 = pair
    return torus_mk((c1.rep, c2.rep))

def check_equivalence() -> bool:
    """Verify left_inv and right_inv on a grid of sample points."""
    pts = [torus_mk((x, y)) for x in (0.0,0.2,0.6) for y in (0.0,0.4,0.9)]
    left = all(of_circles(to_circles(t)) == t for t in pts)
    pairs = [(loop(x), loop(y)) for x in (0.0,0.2,0.6) for y in (0.0,0.4,0.9)]
    right = all(to_circles(of_circles(p)) == p for p in pairs)
    return left and right
