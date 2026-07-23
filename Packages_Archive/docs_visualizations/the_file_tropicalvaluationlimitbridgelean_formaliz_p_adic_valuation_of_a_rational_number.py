from fractions import Fraction
from math import inf
from typing import Union

Val = Union[int, float]

def integer_valuation(n: int, p: int) -> Val:
    if n == 0:
        return inf
    count = 0
    n = abs(n)
    while n % p == 0:
        n //= p
        count += 1
    return count

def padic_valuation(x: Fraction, p: int) -> Val:
    if x == 0:
        return inf
    return integer_valuation(x.numerator, p) - integer_valuation(x.denominator, p)
