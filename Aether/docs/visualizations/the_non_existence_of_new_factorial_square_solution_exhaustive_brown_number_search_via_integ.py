from math import isqrt, factorial
from typing import List, Tuple, Optional


def integer_sqrt_if_square(n: int) -> Optional[int]:
    """Return the exact integer square root of n if n is a perfect square, else None."""
    r: int = isqrt(n)
    return r if r * r == n else None


def brown_numbers_below(bound: int) -> List[Tuple[int, int]]:
    """Return all (n, m) with n < bound and n! + 1 = m^2 (Brocard's equation)."""
    out: List[Tuple[int, int]] = []
    fact: int = 1  # incrementally maintained n!
    for n in range(bound):
        if n >= 1:
            fact *= n
        m: Optional[int] = integer_sqrt_if_square(fact + 1)
        if m is not None:
            out.append((n, m))
    return out


if __name__ == "__main__":
    print(brown_numbers_below(1000))  # -> [(4, 5), (5, 11), (7, 71)]
