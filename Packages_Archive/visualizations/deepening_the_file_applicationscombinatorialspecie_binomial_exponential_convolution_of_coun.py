from fractions import Fraction
from math import comb
from typing import List, Sequence

def bin_conv(a: Sequence[Fraction], b: Sequence[Fraction]) -> List[Fraction]:
    """(a * b)[n] = sum_{i=0}^{n} C(n,i) a[i] b[n-i]."""
    n = min(len(a), len(b))
    out: List[Fraction] = []
    for m in range(n):
        s = Fraction(0)
        for i in range(m + 1):
            s += comb(m, i) * Fraction(a[i]) * Fraction(b[m - i])
        out.append(s)
    return out
