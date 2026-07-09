from __future__ import annotations
from typing import List


def multiplicative_order(p: int, b: int) -> int:
    r = b % p
    k = 1
    while r != 1:
        r = (r * b) % p
        k += 1
    return k


def orbit_sum_digit_prediction(p: int, b: int) -> int:
    """Predict the period digit sum of 1/p in base b via the Master Formula.

    Computes the cyclic subgroup <b> of the nonzero residues modulo p,
    sums its elements to get s, and returns (b-1)*s/p, which equals the
    digit sum of one period.  The quotient is always an integer.
    """
    orbit: List[int] = []
    r = 1 % p
    for _ in range(multiplicative_order(p, b)):
        orbit.append(r)
        r = (r * b) % p
    s = sum(orbit)
    numerator = (b - 1) * s
    assert numerator % p == 0
    return numerator // p
