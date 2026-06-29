from fractions import Fraction
from math import factorial
from typing import List

def egf_coefficients(a: List[Fraction], degree: int) -> List[Fraction]:
    """EGF coefficients [a_0/0!, ..., a_degree/degree!].

    Mathematical foundation: egf(a) = sum_n (a_n / n!) X^n.
    Complexity: O(degree) rational operations after O(degree) factorial setup.
    """
    fact = [Fraction(1)] * (degree + 1)
    for n in range(1, degree + 1):
        fact[n] = fact[n - 1] * n
    return [a[n] / fact[n] for n in range(degree + 1)]
