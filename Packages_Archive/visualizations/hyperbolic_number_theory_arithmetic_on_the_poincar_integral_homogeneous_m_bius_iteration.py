from __future__ import annotations

def integral_mobius_orbit(n: int) -> tuple[int, int]:
    if n < 0:
        raise ValueError("n must be nonnegative")
    a, b = 0, 1
    for _ in range(n):
        a, b = 2 * a + b, a + 2 * b
    return a, b
