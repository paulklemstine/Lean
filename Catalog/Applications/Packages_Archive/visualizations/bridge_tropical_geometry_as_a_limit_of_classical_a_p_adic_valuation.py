"""Algorithm: additive p-adic valuation v_p on the rationals."""
from fractions import Fraction

def p_adic_valuation(x: Fraction, p: int) -> float:
    if x == 0:
        return float("inf")          # v(0) = top element
    num, den, val = x.numerator, x.denominator, 0
    while num % p == 0: num //= p; val += 1
    while den % p == 0: den //= p; val -= 1
    return float(val)
