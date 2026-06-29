from fractions import Fraction
from math import comb
from typing import List, Sequence

def bin_conv(a: Sequence[Fraction], b: Sequence[Fraction]) -> List[Fraction]:
    n = min(len(a), len(b))
    return [sum((comb(m, i) * Fraction(a[i]) * Fraction(b[m - i])
                 for i in range(m + 1)), Fraction(0)) for m in range(n)]

def bin_conv_pow(a: Sequence[Fraction], k: int) -> List[Fraction]:
    N = len(a)
    result = [Fraction(1) if i == 0 else Fraction(0) for i in range(N)]
    base = [Fraction(x) for x in a]
    while k > 0:
        if k & 1:
            result = bin_conv(result, base)
        base = bin_conv(base, base)
        k >>= 1
    return result
