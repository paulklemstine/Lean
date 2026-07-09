import math
from typing import Tuple

def separation_gap(k: int, beta: float) -> Tuple[float, float, float]:
    """Return (split_value, envelope, gap = envelope - split_value)."""
    s: float = math.sqrt(1.0 - beta)
    a: float = 1.0 - s
    split: float = (1.0 - beta) * a ** k
    clique: float = beta ** k * (1.0 - beta)
    star: float = beta * (1.0 - beta) ** k
    env: float = min(clique, star)
    return split, env, env - split
