from fractions import Fraction
from math import comb
from typing import Callable, List

Seq = Callable[[int], Fraction]

def _conv(a: Seq, b: Seq, n: int) -> Fraction:
    return sum((Fraction(comb(n, i)) * a(i) * b(n - i) for i in range(n + 1)),
               Fraction(0))

def leibniz_check(a: Seq, b: Seq, order: int) -> bool:
    """Verify the structural product rule (a*b)' = a'*b + a*b' coefficientwise.
    Returns True iff the identity holds up to the given order."""
    da, db = (lambda n: a(n + 1)), (lambda n: b(n + 1))
    for n in range(order):
        lhs = _conv(a, b, n + 1)                 # (a*b)'_n = (a*b)_{n+1}
        rhs = _conv(da, b, n) + _conv(a, db, n)  # (a'*b + a*b')_n
        if lhs != rhs:
            return False
    return True
