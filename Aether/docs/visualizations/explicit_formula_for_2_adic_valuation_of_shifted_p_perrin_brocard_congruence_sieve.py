from __future__ import annotations
from math import isqrt


def perrin_upto(n_max: int) -> list[int]:
    R: list[int] = [3, 0, 2]
    for i in range(3, n_max + 1):
        R.append(R[i - 2] + R[i - 3])
    return R


def perrin_brocard_solutions(n_max: int) -> list[int]:
    """
    Return all m < n_max with R_m = x^2 + 1 for some integer x.
    The parity sieve removes residues with odd valuation before the square test.
    """
    odd_val = {0, 3, 7, 13, 14, 17, 21, 27}  # residues mod 28 with v2 = 1
    R = perrin_upto(n_max)
    out: list[int] = []
    for m in range(3, n_max):
        if m % 28 in odd_val:
            continue                     # sieved: v2(R_m - 1) is odd
        y = R[m] - 1
        if y >= 0 and isqrt(y) ** 2 == y:
            out.append(m)
    return out
