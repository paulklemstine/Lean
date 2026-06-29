from fractions import Fraction

def p_adic_valuation(n: int, p: int) -> int:
    if n == 0:
        raise ValueError('valuation of 0 is +infinity')
    n = abs(n)
    v = 0
    while n % p == 0:
        n //= p
        v += 1
    return v

def p_adic_abs(q: Fraction, p: int) -> Fraction:
    q = Fraction(q)
    if q == 0:
        return Fraction(0)
    v = p_adic_valuation(q.numerator, p) - p_adic_valuation(q.denominator, p)
    return Fraction(p) ** (-v)
