from fractions import Fraction
from math import factorial
from typing import List

Seq = List[Fraction]

def egf_coeffs(a: Seq) -> Seq:
    """Forward EGF transform: c_n = a_n / n!  (Definition 2.1)."""
    return [a[n] / factorial(n) for n in range(len(a))]

def egf_inverse(c: Seq) -> Seq:
    """Inverse EGF transform: a_n = c_n * n!.

    A two-sided inverse, witnessing injectivity of egf (Theorem 4.1).
    """
    return [c[n] * factorial(n) for n in range(len(c))]
