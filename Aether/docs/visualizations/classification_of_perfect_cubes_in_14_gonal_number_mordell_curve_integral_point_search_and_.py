from __future__ import annotations
from math import isqrt
from typing import List, Tuple


def mordell_integer_points(y_bound: int) -> List[Tuple[int, int]]:
    """All integer (X, Y) on X^2 = 24 Y^3 + 25 with |Y| <= y_bound."""
    points: List[Tuple[int, int]] = []
    for y in range(-y_bound, y_bound + 1):
        rhs = 24 * y ** 3 + 25
        if rhs < 0:
            continue
        x = isqrt(rhs)
        if x * x == rhs:
            points.append((x, y))
            if x != 0:
                points.append((-x, y))
    return points


def tetradecagonal_solutions_via_mordell(y_bound: int) -> List[int]:
    """Recover non-negative n with 6n^2-5n a cube from Mordell points."""
    result = set()
    for x, y in mordell_integer_points(y_bound):
        if (x + 5) % 12 == 0:
            n = (x + 5) // 12
            if n >= 0 and y >= 0 and 6 * n * n - 5 * n == y ** 3:
                result.add(n)
    return sorted(result)
