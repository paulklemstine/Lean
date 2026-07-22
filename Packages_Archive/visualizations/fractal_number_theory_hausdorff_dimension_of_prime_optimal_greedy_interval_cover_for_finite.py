from __future__ import annotations
import math
from typing import Sequence

def minimum_interval_cover(points: Sequence[float], epsilon: float) -> int:
    if epsilon <= 0:
        raise ValueError("epsilon must be positive")
    xs = sorted(points)
    count = i = 0
    while i < len(xs):
        right = xs[i] + epsilon
        count += 1
        i += 1
        while i < len(xs) and xs[i] <= right:
            i += 1
    return count

if __name__ == "__main__":
    sample = [0.0, 0.01, 0.04, 0.11, 0.12, 0.3]
    for eps in (0.2, 0.1, 0.05, 0.01):
        print(eps, minimum_interval_cover(sample, eps))
