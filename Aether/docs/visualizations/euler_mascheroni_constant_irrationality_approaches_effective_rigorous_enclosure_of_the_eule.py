import math
from typing import Tuple

def enclose_gamma(epsilon: float) -> Tuple[float, float]:
    """Return (ell, u) with ell < gamma < u and u - ell < epsilon."""
    n: int = int(math.ceil(1.0 / epsilon)) + 1
    H: float = 0.0
    for k in range(1, n + 1):
        H += 1.0 / k
    ell: float = H - math.log(n + 1)
    u: float = H - math.log(n)
    return ell, u
