from math import isqrt, factorial
from typing import Optional


def integer_sqrt_if_square(n: int) -> Optional[int]:
    r: int = isqrt(n)
    return r if r * r == n else None


def triangular_index(m: int) -> Optional[int]:
    """If m = y(y+1)/2 is triangular, return y; else None.

    Solve y(y+1)/2 = m via the quadratic y = (-1 + sqrt(1 + 8m)) / 2.
    """
    disc: int = 1 + 8 * m
    s: Optional[int] = integer_sqrt_if_square(disc)
    if s is None or (s - 1) % 2 != 0:
        return None
    return (s - 1) // 2


def brown_to_triangle(n: int) -> Optional[int]:
    """For a Brown number n, return the triangular index y with n!/8 = T_y.

    Uses the equivalence n!/8 triangular <=> n!+1 square, and m = 2y+1.
    """
    f: int = factorial(n)
    if f % 8 != 0:
        return None
    return triangular_index(f // 8)


if __name__ == "__main__":
    for n in (4, 5, 7):
        y = brown_to_triangle(n)
        print(f"n={n}: T_index={y}, m=2y+1={2*y+1 if y is not None else None}")
