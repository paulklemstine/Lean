from typing import Callable, Tuple, Sequence
import math

Point = Tuple[float, float]
Gauge = Callable[[float], float]

def dist(p: Point, q: Point) -> float:
    return math.hypot(p[0] - q[0], p[1] - q[1])

def linear_gauge(L: float) -> Gauge:
    """Certified quasi-symmetric gauge eta(t) = L^2 * t of an L-bi-Lipschitz map."""
    assert L >= 1.0
    return lambda t: (L ** 2) * t

def verify_qs(f: Callable[[Point], Point], eta: Gauge,
              triples: Sequence[Tuple[Point, Point, Point]], tol: float = 1e-9) -> bool:
    for x, a, b in triples:
        if dist(x, b) == 0.0:
            continue
        lhs = dist(f(x), f(a))
        rhs = eta(dist(x, a) / dist(x, b)) * dist(f(x), f(b))
        if lhs > rhs + tol:
            return False
    return True