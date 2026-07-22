from fractions import Fraction
from typing import List, Tuple


def fibonacci_convergents(count: int) -> List[Fraction]:
    """Return the first `count` convergents F(n+1)/F(n) of the golden ratio.

    These are the best rational approximations to phi = (1+sqrt(5))/2; among all
    fractions with denominator at most F(n), the fraction F(n+1)/F(n) is closest
    to phi. Runs in O(count) integer additions.
    """
    a, b = 1, 1  # F(1), F(2)
    out: List[Fraction] = []
    for _ in range(count):
        out.append(Fraction(b, a))  # F(n+1) / F(n)
        a, b = b, a + b
    return out


def convergent_pairs(count: int) -> List[Tuple[int, int]]:
    """Return the (numerator, denominator) = (F(n+1), F(n)) pairs."""
    return [(c.numerator, c.denominator) for c in fibonacci_convergents(count)]
