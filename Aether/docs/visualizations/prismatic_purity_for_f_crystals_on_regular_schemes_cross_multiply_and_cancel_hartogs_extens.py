from fractions import Fraction
from math import gcd
from typing import Optional

def is_x_integral(x: int, f: Fraction, max_exponent: int = 256) -> Optional[int]:
    if f.denominator == 1:
        return 0
    if x in (0, 1, -1):
        return None
    power = 1
    for n in range(1, max_exponent + 1):
        power *= x
        if (power * f).denominator == 1:
            return n
    return None

def hartogs_extend(x: int, y: int, f: Fraction) -> int:
    if gcd(x, y) != 1:
        raise ValueError('x, y must be coprime')
    a, b = is_x_integral(x, f), is_x_integral(y, f)
    if a is None or b is None:
        raise ValueError('f must be both x- and y-integral')
    alpha, beta = int(x ** a * f), int(y ** b * f)
    assert (y ** b) * alpha == (x ** a) * beta
    assert alpha % (x ** a) == 0
    gamma = alpha // (x ** a)
    assert Fraction(gamma) == f
    return gamma
