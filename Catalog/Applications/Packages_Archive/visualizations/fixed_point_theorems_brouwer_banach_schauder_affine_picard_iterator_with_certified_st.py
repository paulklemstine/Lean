import math
from typing import Tuple

def affine_picard(a: float, b: float, x0: float, eps: float) -> Tuple[float, int]:
    """Affine Picard iterator with certified stopping time.

    Iterates x <- a*x + b toward the fixed point x* = b/(1-a) (theorem
    `affine_iterate_tendsto`).  The exact a-posteriori error
    |x_n - x*| = |a|^n |x0 - x*| (Remark 6.2) gives a certified iteration
    count n* ensuring |x_{n*} - x*| <= eps.
    """
    assert abs(a) < 1.0 and eps > 0.0
    xstar = b / (1.0 - a)
    d0 = abs(x0 - xstar)
    if d0 <= eps:
        return x0, 0
    # smallest n with |a|^n * d0 <= eps
    n_star = max(0, math.ceil(math.log(eps / d0) / math.log(abs(a)))) if a != 0 else 1
    x = x0
    for _ in range(n_star):
        x = a * x + b
    return x, n_star
