from typing import Callable

def empirical_lipschitz(f: Callable[[float], float], n: int) -> float:
    """
    Estimate the Lipschitz constant of f on [0,1] by maximizing the finite
    difference |f(x_{i+1}) - f(x_i)| / h over a uniform grid of n+1 points.
    For tent^[k] this converges to the exact constant 2^k.
    """
    h = 1.0 / n
    best = 0.0
    prev = f(0.0)
    for i in range(1, n + 1):
        cur = f(i * h)
        best = max(best, abs(cur - prev) / h)
        prev = cur
    return best
