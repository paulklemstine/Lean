from typing import Tuple

def compose_sum_of_two_squares(a: int, b: int, c: int, d: int) -> Tuple[int, int]:
    """Brahmagupta-Fibonacci composition.

    Given (a, b) and (c, d) representing a^2+b^2 and c^2+d^2, return (x, y) with
    x^2 + y^2 = (a^2+b^2)*(c^2+d^2). This is the coordinate form of the Gaussian
    norm multiplicativity N(z*w) = N(z)*N(w).
    """
    x = a * c - b * d
    y = a * d + b * c
    return (x, y)
