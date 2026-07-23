from fractions import Fraction
from itertools import product
from typing import Callable, List

def p_adic_valuation(n: int, p: int) -> int:
    n = abs(n); v = 0
    while n % p == 0:
        n //= p; v += 1
    return v

def p_adic_abs(q: Fraction, p: int) -> Fraction:
    q = Fraction(q)
    if q == 0:
        return Fraction(0)
    v = p_adic_valuation(q.numerator, p) - p_adic_valuation(q.denominator, p)
    return Fraction(p) ** (-v)

def dist_p(x: Fraction, y: Fraction, p: int) -> Fraction:
    return p_adic_abs(Fraction(x) - Fraction(y), p)

def certify_integer_affine(m: int, c: int, p: int) -> bool:
    additive = True                       # constant cancels in differences
    monotone = p_adic_abs(Fraction(m), p) <= 1
    return additive and monotone          # => nonexpansive by the bridge theorem

def validate(f: Callable[[Fraction], Fraction], p: int,
             samples: List[Fraction]) -> bool:
    return all(dist_p(f(x), f(y), p) <= dist_p(x, y, p)
               for x, y in product(samples, samples))
