import math
from typing import List, Dict

def monomial_synth(k: int, h: float, x: float) -> float:
    u = h * x
    partial, term = 0.0, 1.0
    for m in range(k):
        partial += term
        term *= u / (m + 1)
    return (math.factorial(k) / h ** k) * (math.exp(u) - partial)

def poly_approx(coeffs: List[float], h: float, x: float) -> float:
    acc = (coeffs[0] if len(coeffs) > 0 else 0.0)
    if len(coeffs) > 1:
        acc += coeffs[1] * x
    for k in range(2, len(coeffs)):
        acc += coeffs[k] * monomial_synth(k, h, x)
    return acc

def error_budget(coeffs: List[float], h: float,
                 constants: Dict[int, float]) -> float:
    return h * sum(abs(coeffs[k]) * constants.get(k, 0.0)
                   for k in range(2, len(coeffs)))
