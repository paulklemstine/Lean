from fractions import Fraction
from typing import List, Tuple


def exact_variance(p: int, b: int, remainders: List[int],
                   digits: List[int]) -> Fraction:
    """Compute the exact digit variance of the repetend of 1/p in base b
    from the remainder-orbit sums, and verify the three closed-form
    identities (digit-sum, sum-of-squares, and variance).
    """
    l: int = len(digits)
    R: int = sum(remainders)
    Q: int = sum(r * r for r in remainders)
    C: int = sum(remainders[k] * remainders[(k + 1) % l] for k in range(l))
    S: int = sum(digits)
    T: int = sum(d * d for d in digits)
    assert p * S == (b - 1) * R
    assert p * p * T + 2 * b * C == (b * b + 1) * Q
    numerator: int = l * ((b * b + 1) * Q - 2 * b * C) - (b - 1) ** 2 * R * R
    assert p * p * (l * T - S * S) == numerator
    return Fraction(numerator, p * p * l * l)
