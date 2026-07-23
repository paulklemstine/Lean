import math

def binary_renyi_entropy(alpha: float, p: float) -> float:
    powa = lambda x: 0.0 if x == 0.0 else x ** alpha
    return (1.0 / (1.0 - alpha)) * math.log2(powa(p) + powa(1.0 - p))

def phase_boundary_rate(rho: float, p: float) -> float:
    """Critical rate R*(rho, p) = 1 - H_{1/(1+rho)}(p) where E_coset = 0.

    O(1). For R > R* guessing is exponentially hard; for R < R* the moment
    decays sub-exponentially.
    """
    return 1.0 - binary_renyi_entropy(1.0 / (1.0 + rho), p)

def secure_rate_interval(rho: float, p: float) -> tuple[float, float]:
    """Return the interval of rates (R*, 1] that guarantee a positive exponent."""
    Rstar = phase_boundary_rate(rho, p)
    return (max(0.0, Rstar), 1.0)
