from __future__ import annotations

def closed_form_coordinates(n: int) -> tuple[int, int]:
    if n < 0:
        raise ValueError("n must be nonnegative")
    power = pow(3, n)
    return (power - 1) // 2, (power + 1) // 2
