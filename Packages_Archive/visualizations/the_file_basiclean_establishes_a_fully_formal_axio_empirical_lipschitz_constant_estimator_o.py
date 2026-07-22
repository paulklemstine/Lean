from typing import Callable, List


def empirical_lipschitz(f: Callable[[float], float],
                        a: float, b: float, n: int) -> float:
    """Max finite-difference slope of f on [a,b]; -> 2^k for tent^[k] on its ramp."""
    xs: List[float] = [a + (b - a) * i / n for i in range(n + 1)]
    best: float = 0.0
    for i in range(n):
        dx = xs[i + 1] - xs[i]
        if dx == 0.0:
            continue
        best = max(best, abs(f(xs[i + 1]) - f(xs[i])) / dx)
    return best