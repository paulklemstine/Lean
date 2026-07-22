from __future__ import annotations
from fractions import Fraction
def padic_valuation(q: Fraction, p: int) -> int:
    if q == 0: raise ValueError("v_p(0) is not finite")
    a, b, value = abs(q.numerator), q.denominator, 0
    while a % p == 0: a //= p; value += 1
    while b % p == 0: b //= p; value -= 1
    return value
def in_cluster(y: Fraction, x: Fraction, p: int, k: int) -> bool:
    return y == x or padic_valuation(x - y, p) >= k
