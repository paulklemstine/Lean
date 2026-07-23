from typing import Callable, List
import math

def riccati_solution(A: float, B: float) -> Callable[[float], float]:
    """v(x) = y'/y for y = A e^x + B e^{-x}, a solution of v' + v^2 = 1."""
    def v(x: float) -> float:
        ex, emx = math.exp(x), math.exp(-x)
        return (A * ex - B * emx) / (A * ex + B * emx)
    return v

def cross_ratio(a: float, b: float, c: float, d: float) -> float:
    """Projective invariant [a,b;c,d] = (a-c)(b-d)/((a-d)(b-c))."""
    return ((a - c) * (b - d)) / ((a - d) * (b - c))

def verify_cross_ratio_constant(params: List[tuple], xs: List[float]) -> float:
    """Return max variation of the cross-ratio of four Riccati solutions over xs."""
    vs = [riccati_solution(A, B) for (A, B) in params]
    values = [cross_ratio(vs[0](x), vs[1](x), vs[2](x), vs[3](x)) for x in xs]
    return max(values) - min(values)
