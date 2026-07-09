import math
from typing import Dict

CONSTANTS: Dict[int, float] = {2: 4.0 / 9.0, 3: 5.0 / 16.0}

def width_for_accuracy(k: int, eps: float) -> int:
    """Smallest width n with proved uniform error <= eps for x**k on [0,1]."""
    if eps <= 0:
        raise ValueError("eps must be positive")
    if k not in CONSTANTS:
        raise ValueError(f"no proved constant for degree {k}")
    return math.ceil(CONSTANTS[k] / eps)
