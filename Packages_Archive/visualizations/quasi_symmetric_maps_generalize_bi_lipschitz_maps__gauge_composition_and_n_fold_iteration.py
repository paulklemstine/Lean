from typing import Callable

Gauge = Callable[[float], float]

def compose_gauges(eta_g: Gauge, eta_f: Gauge) -> Gauge:
    """Theorem 4.3: gauge of g . f is eta_g . eta_f."""
    return lambda t: eta_g(eta_f(t))

def iterate_gauge(eta: Gauge, n: int) -> Gauge:
    """Theorem 4.4: gauge of f^[n] is eta^[n]."""
    def g(t: float) -> float:
        out = t
        for _ in range(n):
            out = eta(out)
        return out
    return g