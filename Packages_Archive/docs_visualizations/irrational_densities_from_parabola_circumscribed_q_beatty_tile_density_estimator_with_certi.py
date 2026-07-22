import math
from typing import Tuple

def tile_density_with_bounds(alpha: float, n: int) -> Tuple[float, float, float]:
    count = math.floor(n * alpha)
    rho = count / n
    return rho, alpha - 1.0 / n, alpha
