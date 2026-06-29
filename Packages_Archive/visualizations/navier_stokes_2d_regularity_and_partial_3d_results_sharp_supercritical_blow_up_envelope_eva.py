import math
from typing import Callable, Tuple

def blowup_envelope_check(c: float, z0: float, n: int = 20000
                          ) -> Tuple[float, float]:
    """Integrate Z' = C Z^3 and compare to the sharp lower envelope."""
    t_star: float = 1.0 / (2.0 * c * z0 ** 2)
    envelope: Callable[[float], float] = (
        lambda t: 1.0 / math.sqrt(2.0 * c * (t_star - t)))
    h: float = 0.99 * t_star / n
    t, z, err = 0.0, z0, 0.0
    f: Callable[[float], float] = lambda y: c * y ** 3
    for _ in range(n):
        k1 = f(z); k2 = f(z + 0.5*h*k1)
        k3 = f(z + 0.5*h*k2); k4 = f(z + h*k3)
        z += (h/6.0)*(k1 + 2*k2 + 2*k3 + k4); t += h
        err = max(err, abs(z - envelope(t)) / envelope(t))
    return (t_star, err)
