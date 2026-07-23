from fractions import Fraction
from math import factorial
from typing import List, Sequence

def egf_coeffs(a: Sequence[Fraction], n_terms: int) -> List[Fraction]:
    return [Fraction(a[n]) / factorial(n) for n in range(n_terms)]

def cauchy_product(p: Sequence[Fraction], q: Sequence[Fraction], n_terms: int) -> List[Fraction]:
    out: List[Fraction] = []
    for n in range(n_terms):
        s = Fraction(0)
        for i in range(n + 1):
            s += Fraction(p[i]) * Fraction(q[n - i])
        out.append(s)
    return out
