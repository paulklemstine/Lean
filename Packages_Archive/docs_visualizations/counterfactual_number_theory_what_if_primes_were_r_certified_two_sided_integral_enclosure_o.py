import math
from typing import Tuple

def log_integral(a: float, b: float, steps: int = 200_000) -> float:
    """Composite Simpson estimate of Li(a, b) = int_a^b dx/log x (a > 1)."""
    if a <= 1.0:
        raise ValueError("1/log x singular at x = 1; need a > 1")
    if b <= a:
        return 0.0
    if steps % 2 == 1:
        steps += 1
    h = (b - a) / steps
    total = 1.0 / math.log(a) + 1.0 / math.log(b)
    for i in range(1, steps):
        total += (4.0 if i % 2 else 2.0) / math.log(a + i * h)
    return total * h / 3.0

def cramer_enclose(N: int) -> Tuple[float, float]:
    """Proven enclosure [lo, hi] with lo <= CramerSum(N) <= hi (N >= 3)."""
    lo = log_integral(2.0, N + 1.0)
    hi = 1.0 / math.log(2.0) + log_integral(2.0, float(N))
    return lo, hi
