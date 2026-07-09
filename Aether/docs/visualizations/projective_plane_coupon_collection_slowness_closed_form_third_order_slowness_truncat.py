from math import comb
from fractions import Fraction
from typing import Tuple


def order3_truncation(q: int) -> Tuple[Fraction, Fraction]:
    """Closed-form order-three truncation E^(3) = S1 - S2 + S3 for any prime
    power q. Orders 1 and 2 are identical for the two mechanisms; the strict
    surplus lives entirely in order 3, where the plane carries two distinct
    triple avoid-probabilities (collinear vs generic) with the uniform mean.
    Returns (plane, uniform); the difference is positive for all q. O(1) work.
    """
    n = q * q + q + 1
    u1 = Fraction(q * q, n)
    u2 = Fraction(q * q * (q * q - 1), n * (n - 1))
    u3 = Fraction(q * q * (q * q - 1) * (q * q - 2), n * (n - 1) * (n - 2))
    p_point = Fraction(q * q, n)
    p_pair = Fraction(q * q - q, n)
    p_coll = Fraction(q * q - 2 * q, n)
    p_gen = Fraction((q - 1) ** 2, n)
    n_coll = n * comb(q + 1, 3)
    n_gen = comb(n, 3) - n_coll
    uniform = comb(n, 1) / (1 - u1) - comb(n, 2) / (1 - u2) + comb(n, 3) / (1 - u3)
    plane = (comb(n, 1) / (1 - p_point) - comb(n, 2) / (1 - p_pair)
             + n_coll / (1 - p_coll) + n_gen / (1 - p_gen))
    return plane, uniform
