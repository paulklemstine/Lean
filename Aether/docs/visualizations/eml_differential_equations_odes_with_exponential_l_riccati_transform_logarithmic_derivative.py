from typing import Callable, List

def numeric_derivative(f: Callable[[float], float], x: float,
                       h: float = 1e-6) -> float:
    return (f(x + h) - f(x - h)) / (2.0 * h)

def riccati_transform(y: Callable[[float], float],
                      a: float,
                      samples: List[float]) -> List[float]:
    """Return residuals v' + v^2 - a for v = y'/y; ~0 when y'' = a y."""
    v: Callable[[float], float] = lambda x: numeric_derivative(y, x) / y(x)
    return [numeric_derivative(v, x) + v(x) ** 2 - a for x in samples]
