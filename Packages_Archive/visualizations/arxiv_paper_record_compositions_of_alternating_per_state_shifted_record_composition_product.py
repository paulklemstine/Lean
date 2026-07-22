from math import comb
from typing import Sequence

def euler_zigzag_table(max_n: int) -> list[int]:
    if max_n < 0:
        raise ValueError("max_n must be nonnegative")
    row, values = [1], [1]
    for n in range(1, max_n + 1):
        new = [0] * (n + 1)
        for k in range(1, n + 1):
            new[k] = new[k - 1] + row[n - k]
        row = new
        values.append(row[-1])
    return values

def weight(alpha: Sequence[int], start: int = 0) -> int:
    if start < 0 or any(a <= 0 for a in alpha):
        raise ValueError("start must be nonnegative and parts positive")
    euler = euler_zigzag_table(max((2*a-1 for a in alpha), default=0))
    total, result = start, 1
    for a in alpha:
        total += a
        result *= comb(2*total-1, 2*a-1) * euler[2*a-1]
    return result
