from math import comb
from fractions import Fraction
from typing import List, Sequence

def bin_conv(a: Sequence[Fraction], b: Sequence[Fraction], n_terms: int) -> List[Fraction]:
    out: List[Fraction] = []
    for n in range(n_terms):
        s = Fraction(0)
        for i in range(n + 1):
            s += comb(n, i) * Fraction(a[i]) * Fraction(b[n - i])
        out.append(s)
    return out
