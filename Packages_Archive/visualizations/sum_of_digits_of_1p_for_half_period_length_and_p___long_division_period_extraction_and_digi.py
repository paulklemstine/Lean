from __future__ import annotations
from typing import List, Tuple


def multiplicative_order(p: int, b: int) -> int:
    """Least L >= 1 with b^L = 1 (mod p); requires gcd(b, p) = 1."""
    r = b % p
    k = 1
    while r != 1:
        r = (r * b) % p
        k += 1
    return k


def digit_sum_by_long_division(p: int, b: int) -> Tuple[int, List[int]]:
    """One period of base-b digits of 1/p and their sum via long division.

    Iterates the remainder map r -> (b*r) mod p, emitting the digit
    floor(b*r / p) at each step, halting when the remainder returns to 1.
    Runs in O(L) integer multiplications where L = ord_p(b).
    """
    length = multiplicative_order(p, b)
    r = 1 % p
    digits: List[int] = []
    for _ in range(length):
        digits.append((b * r) // p)
        r = (b * r) % p
    return sum(digits), digits
