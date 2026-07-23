from __future__ import annotations
from typing import List


def is_sum_of_two_squares(n: int) -> bool:
    """n is a sum of two squares iff every prime p == 3 (mod 4) divides n evenly."""
    if n < 0:
        return False
    if n == 0:
        return True
    m, p = n, 2
    while p * p <= m:
        if m % p == 0:
            e = 0
            while m % p == 0:
                m //= p
                e += 1
            if p % 4 == 3 and e % 2 == 1:
                return False
        p += 1
    return not (m > 1 and m % 4 == 3)


def count_sign_changes_over_Sm(coeffs: List[float], m: int, N: int) -> int:
    """Count sign changes of coeffs[1..N] restricted to sums of m squares."""
    if m >= 4:
        indices = range(1, N + 1)                      # S_m = N (collapse)
    elif m == 2:
        indices = (n for n in range(1, N + 1) if is_sum_of_two_squares(n))
    else:
        raise ValueError("only m == 2 or m >= 4 supported here")
    prev, changes = 0, 0
    for n in indices:
        v = coeffs[n]
        s = (v > 0) - (v < 0)
        if s == 0:
            continue
        if prev != 0 and s != prev:
            changes += 1
        prev = s
    return changes
