from fractions import Fraction
from typing import Callable

Diamond = Callable[[int, int], Fraction]


def euler_char(n: int, h: Diamond) -> Fraction:
    """Alternating double sum chi(n, h) = sum_{p,q=0}^{n} (-1)^{p+q} h(p,q).

    Runs in O((n+1)^2) ring operations.
    """
    total = Fraction(0)
    for p in range(n + 1):
        sign_p = (-1) ** p
        for q in range(n + 1):
            total += Fraction(sign_p * (-1) ** q) * h(p, q)
    return total
