from fractions import Fraction
from math import comb
from typing import List

def binomial_convolution(a: List[Fraction], b: List[Fraction],
                         degree: int) -> List[Fraction]:
    """Binomial (exponential) convolution truncated to `degree`.

    (a * b)_n = sum_{i+j=n} C(n,i) a_i b_j   (Definition 2.2).
    Combinatorially: count combined structures formed by choosing a subset S of
    [n], an A-structure on S, and a B-structure on its complement.
    Under egf this convolution becomes the ordinary Cauchy product (Theorem 2.4).
    Complexity: O(degree^2) rational operations.
    """
    out: List[Fraction] = []
    for n in range(degree + 1):
        s = Fraction(0)
        for i in range(n + 1):
            s += Fraction(comb(n, i)) * a[i] * b[n - i]
        out.append(s)
    return out
