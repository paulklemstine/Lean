import math
from typing import Tuple

def gudermannian(y: float) -> float:
    """gd(y) = 2*arctan(e^y) - pi/2, an antiderivative of sech(y)."""
    return 2.0 * math.atan(math.exp(y)) - math.pi / 2.0

def rectangle_metric_area(x1: float, x2: float, y1: float, y2: float) -> float:
    """Exact Split-Geometry area of the coordinate rectangle [x1,x2]x[y1,y2].
    The Riemannian area density is sqrt(E*G) = cosh(x)/cosh(y); since
    integral cosh(x) dx = sinh(x) and integral sech(y) dy = gd(y), the area
    factorizes as (sinh x2 - sinh x1)(gd y2 - gd y1)."""
    return ((math.sinh(x2) - math.sinh(x1))
            * (gudermannian(y2) - gudermannian(y1)))

def triangle_metric_area(p1: Tuple[float, float], p2: Tuple[float, float],
                         p3: Tuple[float, float], n: int = 400) -> float:
    """Metric area of a triangle by barycentric midpoint quadrature of the
    density cosh(x)/cosh(y)."""
    (x1, y1), (x2, y2), (x3, y3) = p1, p2, p3
    euclid = 0.5 * abs((x2 - x1) * (y3 - y1) - (x3 - x1) * (y2 - y1))
    total, count = 0.0, 0
    for i in range(n):
        for j in range(n - i):
            s = (i + 1.0 / 3.0) / n
            t = (j + 1.0 / 3.0) / n
            u = 1.0 - s - t
            if u < 0.0:
                continue
            x = s * x1 + t * x2 + u * x3
            y = s * y1 + t * y2 + u * y3
            total += math.cosh(x) / math.cosh(y)
            count += 1
    return total / count * euclid if count else 0.0
