import math

def spectral_gap(beta: float, J: float) -> float:
    """Spectral gap g = log cosh(beta J) - log sinh(beta J) = log coth(beta J)."""
    bj = beta * J
    return math.log(math.cosh(bj)) - math.log(math.sinh(bj))

def correlation_length(beta: float, J: float) -> float:
    """Correlation length xi = 1 / g  (= inverse transfer-matrix spectral gap)."""
    return 1.0 / spectral_gap(beta, J)

def correlation_via_gap(beta: float, J: float, n: int) -> float:
    """<s0 sn> = exp(-g n)  (theorem corr_eq_exp_neg_gap)."""
    return math.exp(-spectral_gap(beta, J) * n)
