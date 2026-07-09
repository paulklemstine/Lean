from math import factorial, isqrt
from typing import List, Optional, Tuple


def is_perfect_square(s: int) -> Optional[int]:
    """Return m with m*m == s if s is a perfect square, else None."""
    if s < 0:
        return None
    r = isqrt(s)
    return r if r * r == s else None


def brown_scan(n_lo: int, n_hi: int) -> List[Tuple[int, int, int]]:
    """
    Scan n in [n_lo, n_hi] and return all Brown triples (n, m, y) where
    n! + 1 = m^2 and, equivalently, n!/8 = T_y is the y-th triangular number.

    Method: by the discriminant identity 8*T_y + 1 = (2y+1)^2, n is a Brown
    number iff 8*(n!/8) + 1 = n! + 1 is a perfect square m^2, in which case m
    is odd and the triangular index is y = (m - 1) // 2.
    Complexity: O((n_hi - n_lo) * M(N)) where N ~ n_hi*log(n_hi) bits and
    M(N) is the cost of an isqrt on an N-bit integer.
    """
    results: List[Tuple[int, int, int]] = []
    f = factorial(max(n_lo - 1, 0))
    for n in range(max(n_lo, 1), n_hi + 1):
        f *= n  # incremental factorial: f == n!
        m = is_perfect_square(f + 1)
        if m is not None:
            y = (m - 1) // 2  # m is odd, exact
            results.append((n, m, y))
    return results
