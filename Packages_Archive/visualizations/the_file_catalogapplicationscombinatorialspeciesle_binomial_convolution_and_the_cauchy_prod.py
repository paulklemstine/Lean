from fractions import Fraction
from math import comb
from typing import Callable, List

Seq = Callable[[int], Fraction]

def bin_conv(a: Seq, b: Seq, order: int) -> List[Fraction]:
    """Binomial (exponential) convolution (a*b)_n = sum_{i+j=n} C(n,i) a_i b_j,
    the counting sequence of the Day-convolution product of species."""
    out: List[Fraction] = []
    for n in range(order):
        out.append(sum((Fraction(comb(n, i)) * a(i) * b(n - i)
                        for i in range(n + 1)), Fraction(0)))
    return out

def cauchy_product(f: List[Fraction], g: List[Fraction], order: int) -> List[Fraction]:
    """Ordinary power-series product; equals EGF of the binomial convolution."""
    return [sum((f[i] * g[n - i] for i in range(n + 1)), Fraction(0))
            for n in range(order)]
