import math
from fractions import Fraction

def p_adic_valuation(x: Fraction, p: int) -> float:
    if x == 0:
        return math.inf
    num, den = abs(x.numerator), abs(x.denominator)
    k = 0
    while num % p == 0:
        num //= p; k += 1
    while den % p == 0:
        den //= p; k -= 1
    return float(k)
