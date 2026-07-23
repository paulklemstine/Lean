from dataclasses import dataclass
from typing import Callable, Tuple, TypeVar
X = TypeVar("X")

@dataclass(frozen=True)
class Torus:
    x: float
    y: float

def torus_mk(p: Tuple[float, float]) -> Torus:
    """Canonical square map; glues bottom~top and left~right."""
    x, y = p
    nx = 0.0 if abs(x - 1.0) <= 1e-12 else x
    ny = 0.0 if abs(y - 1.0) <= 1e-12 else y
    return Torus(nx, ny)

def torus_rec(f: Callable[[Tuple[float, float]], X], hh: bool, hv: bool) -> Callable[[Torus], X]:
    """Torus.rec': lift a square map f with edge tolls hh, hv to T^2 -> X."""
    if not (hh and hv):
        raise ValueError("edge tolls not satisfied")
    def induced(t: Torus) -> X:
        return f((t.x, t.y))
    return induced
