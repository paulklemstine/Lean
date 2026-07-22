import math

def closed_form_correlation(beta: float, J: float, n: int) -> float:
    """Exact <s0 sn> = (tanh(beta J))^n  (theorem corr_eq_tanh_pow)."""
    return math.tanh(beta * J) ** n

def partition_function(beta: float, J: float, n: int) -> float:
    """Z = 2 (2 cosh(beta J))^n  (theorem Zfree_closed)."""
    return 2.0 * (2.0 * math.cosh(beta * J)) ** n

def unnormalised_correlation(beta: float, J: float, n: int) -> float:
    """corrNum = 2 (2 sinh(beta J))^n  (theorem corrNum_closed)."""
    return 2.0 * (2.0 * math.sinh(beta * J)) ** n
