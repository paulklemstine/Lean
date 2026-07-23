from typing import Tuple
import math

def pyth_to_bernoulli(a: float, b: float, c: float
                      ) -> Tuple[float, float, float, float, float]:
    """Encode a Pythagorean triple as a Bernoulli law (+ moments)."""
    p: float = (a / c) ** 2
    q: float = (b / c) ** 2
    var: float = p * q
    return p, q, var, p - q, math.sqrt(var)
