from fractions import Fraction
from math import comb
from typing import List

def conv_unit(degree: int) -> List[Fraction]:
    """The convolution unit (1, 0, 0, ...)."""
    return [Fraction(1) if n == 0 else Fraction(0) for n in range(degree + 1)]

def binomial_convolution(a: List[Fraction], b: List[Fraction],
                         degree: int) -> List[Fraction]:
    out: List[Fraction] = []
    for n in range(degree + 1):
        out.append(sum((Fraction(comb(n, i)) * a[i] * b[n - i]
                        for i in range(n + 1)), Fraction(0)))
    return out

def conv_power(a: List[Fraction], k: int, degree: int) -> List[Fraction]:
    """k-fold binomial convolution a^*k (Definition 6.1).

    Foundation: egf(a^*k) = (egf a)^k (Theorem 6.2); the algebraic engine of the
    exponential formula. The result a^*k counts assemblies of k independent
    labelled blocks each carrying an a-structure.
    Complexity: O(k * degree^2).
    """
    result = conv_unit(degree)
    for _ in range(k):
        result = binomial_convolution(result, a, degree)
    return result
