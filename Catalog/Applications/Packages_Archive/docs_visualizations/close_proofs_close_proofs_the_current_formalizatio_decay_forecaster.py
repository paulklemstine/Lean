import math
from typing import Tuple

def forecast(b: int, k: int, d: int, budget: float = 1e-9
             ) -> Tuple[float, float, bool]:
    fraction = (k / b) ** d
    info = d * (math.log(b) - math.log(k))
    return (fraction, info, fraction >= budget)
