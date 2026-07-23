import math

def constrained_coset_exponent(rho: float, R: float, p: float) -> float:
    """Closed-form constrained coset guessing exponent
        E_coset(rho, R, p) = (1+rho) log2(p^a + (1-p)^a) - rho*(1-R),  a = 1/(1+rho).
    Runs in O(1) arithmetic operations.
    """
    a = 1.0 / (1.0 + rho)
    powa = lambda x: 0.0 if x == 0.0 else x ** a
    return (1.0 + rho) * math.log2(powa(p) + powa(1.0 - p)) - rho * (1.0 - R)
