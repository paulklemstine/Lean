from __future__ import annotations
import math

def distance(n: int) -> float:
    return 2.0 * math.asinh(abs(n) / 2.0)

def count_in_ball(R: float) -> int:
    if R < 0:
        raise ValueError("R must be nonnegative")
    bound = math.floor(2.0 * math.sinh(R / 2.0) + 1e-12)
    return 2*bound + 1

for R in (0.0, 1.0, 2.0, 4.0, 6.0):
    print(f"R={R:.1f}: {count_in_ball(R)} points")
