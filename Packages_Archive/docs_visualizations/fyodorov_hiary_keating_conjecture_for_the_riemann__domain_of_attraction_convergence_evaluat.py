import math
from typing import Callable

def gumbel_cdf(x: float) -> float:
    return math.exp(-math.exp(-x))

def domain_of_attraction_limit(
    survival: Callable[[float], float],
    a: Callable[[int], float],
    b: Callable[[int], float],
    x: float,
    n: int,
) -> float:
    """Approximate F(a_n + b_n x)^n for a CDF given via its survival function.

    `survival(y)` returns 1 - F(y). Under the Gumbel domain-of-attraction
    condition n*(1 - F(a_n + b_n x)) -> e^{-x}, this quantity converges to
    the Gumbel CDF G(x) = exp(-exp(-x)) as n -> infinity.
    """
    y = a(n) + b(n) * x
    cdf_val = 1.0 - survival(y)
    return cdf_val ** n
