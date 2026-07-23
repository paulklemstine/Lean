from typing import Tuple
import math

def bernoulli_to_pyth(p: float) -> Tuple[float, float, float]:
    """Realize a Bernoulli probability as a canonical right triangle."""
    if not (0.0 < p < 1.0):
        raise ValueError('p must lie in the open interval (0, 1)')
    return math.sqrt(p), math.sqrt(1.0 - p), 1.0
