from __future__ import annotations
import math
from typing import List, Tuple


def four_square_decomposition(n: int) -> Tuple[int, int, int, int]:
    """Return (a, b, c, d) with a^2 + b^2 + c^2 + d^2 = n (Lagrange)."""
    if n < 0:
        raise ValueError("n must be non-negative")
    a = 0
    while a * a <= n:
        ra = n - a * a
        b = a
        while b * b <= ra:
            rb = ra - b * b
            c = b
            while c * c <= rb:
                rc = rb - c * c
                d = math.isqrt(rc)
                if d * d == rc:
                    return (a, b, c, d)
                c += 1
            b += 1
        a += 1
    raise RuntimeError("unreachable: Lagrange guarantees a decomposition")


def sum_of_m_squares_certificate(m: int, n: int) -> List[int]:
    """Length-m list of non-negative integers whose squares sum to n (m >= 4)."""
    if m < 4:
        raise ValueError("padding argument requires m >= 4")
    a, b, c, d = four_square_decomposition(n)
    return [a, b, c, d] + [0] * (m - 4)
