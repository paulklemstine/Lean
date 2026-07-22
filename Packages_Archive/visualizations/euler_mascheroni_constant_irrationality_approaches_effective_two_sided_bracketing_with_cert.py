import math
from typing import Tuple

def gamma_bracket(n: int) -> Tuple[float, float, float]:
    """Return (lower, upper, width) with lower < gamma < upper, width < 1/n."""
    H: float = math.fsum(1.0 / k for k in range(1, n + 1))
    lower: float = H - math.log(n + 1)
    upper: float = H - math.log(n)
    return lower, upper, upper - lower
