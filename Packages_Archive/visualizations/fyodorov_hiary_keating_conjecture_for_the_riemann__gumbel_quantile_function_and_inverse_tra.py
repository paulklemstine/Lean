import math

def gumbel_cdf(x: float) -> float:
    """Standard Gumbel CDF G(x) = exp(-exp(-x))."""
    return math.exp(-math.exp(-x))

def gumbel_quantile(p: float) -> float:
    """Inverse CDF (quantile) of the Gumbel law: G^{-1}(p) = -log(-log p).

    Valid for 0 < p < 1. Used for exact inverse-transform sampling and for
    computing quantiles/medians of the extreme-value law.
    """
    if not (0.0 < p < 1.0):
        raise ValueError("p must lie strictly in (0, 1)")
    return -math.log(-math.log(p))
