from __future__ import annotations
from typing import List, Tuple


def integer_cube_root(x: int) -> "int | None":
    if x < 0:
        return None
    t = round(x ** (1.0 / 3.0)) if x > 0 else 0
    for c in (t - 1, t, t + 1):
        if c >= 0 and c * c * c == x:
            return c
    return None


def classify_tetradecagonal_cubes(bound: int) -> List[Tuple[int, int]]:
    """Return all (n, t) with 0 <= n <= bound and 6n^2 - 5n = t^3."""
    solutions: List[Tuple[int, int]] = []
    for n in range(bound + 1):
        value = 6 * n * n - 5 * n
        t = integer_cube_root(value)
        if t is not None:
            solutions.append((n, t))
    return solutions
