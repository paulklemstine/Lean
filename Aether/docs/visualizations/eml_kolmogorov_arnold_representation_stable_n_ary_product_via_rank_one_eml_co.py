import math
from typing import Sequence

def product_via_eml(x: Sequence[float]) -> float:
    """Rank-one EML form of the n-ary product on positive inputs:
        prod_i x_i = exp( sum_i log x_i ).
    Numerically stable (log-sum-exp style) for long positive products."""
    if any(xi <= 0 for xi in x):
        raise ValueError("requires strictly positive inputs")
    return math.exp(sum(math.log(xi) for xi in x))
