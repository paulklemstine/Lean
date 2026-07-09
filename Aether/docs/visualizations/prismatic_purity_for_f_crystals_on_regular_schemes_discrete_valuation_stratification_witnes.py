from fractions import Fraction

def p_adic_valuation(p: int, f: Fraction) -> int:
    if f == 0:
        raise ValueError('valuation of 0 is undefined')
    num, den, v = f.numerator, f.denominator, 0
    while num % p == 0:
        num //= p; v += 1
    while den % p == 0:
        den //= p; v -= 1
    return v
