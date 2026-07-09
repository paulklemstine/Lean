from typing import Callable, Tuple, List

def diagonal_limit_estimate(
    f: Callable[[float], float], fp: Callable[[float], float],
    g: Callable[[float], float], gp: Callable[[float], float],
    x: float, h: float = 1e-3,
) -> Tuple[float, float, float]:
    k_xh = (f(x) * g(x + h) - g(x) * f(x + h)) / (x - (x + h))
    w_x = f(x) * gp(x) - g(x) * fp(x)
    return k_xh, -w_x, abs(k_xh - (-w_x))

def sweep(
    f: Callable[[float], float], fp: Callable[[float], float],
    g: Callable[[float], float], gp: Callable[[float], float],
    base_points: List[float], h: float = 1e-3,
) -> List[Tuple[float, float, float]]:
    return [diagonal_limit_estimate(f, fp, g, gp, x, h) for x in base_points]
