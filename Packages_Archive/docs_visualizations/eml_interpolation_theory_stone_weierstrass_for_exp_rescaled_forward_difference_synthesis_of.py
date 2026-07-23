import math
from typing import Callable

def monomial_synth(k: int, h: float, x: float) -> float:
    """Rescaled k-th forward difference of exp; approximates x**k on [0,1]."""
    if h <= 0:
        raise ValueError("step h must be positive")
    u = h * x
    partial = 0.0
    term = 1.0  # (hx)^0 / 0!
    for m in range(k):
        partial += term
        term *= u / (m + 1)
    fact_k = math.factorial(k)
    return (fact_k / h ** k) * (math.exp(u) - partial)

def monomial_network(k: int, n: int) -> Callable[[float], float]:
    """Width-n EML network for x**k with step h = 1/n."""
    h = 1.0 / n
    return lambda x: monomial_synth(k, h, x)
