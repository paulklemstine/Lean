import math

def gamma_lower(n: int) -> float:
    """Lower approximant seq(n)=H_n-ln(n+1); error < 1/n."""
    H: float = math.fsum(1.0 / k for k in range(1, n + 1))
    return H - math.log(n + 1)
