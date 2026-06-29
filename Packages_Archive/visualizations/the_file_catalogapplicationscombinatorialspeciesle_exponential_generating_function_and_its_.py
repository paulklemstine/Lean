from fractions import Fraction
from math import factorial
from typing import Callable, List

Seq = Callable[[int], Fraction]

def egf_coeffs(a: Seq, order: int) -> List[Fraction]:
    """Coefficients [X^n] EGF(a) = a_n / n! for n = 0 .. order-1."""
    return [a(n) / Fraction(factorial(n)) for n in range(order)]

def seq_of(coeffs: List[Fraction]) -> List[Fraction]:
    """Explicit inverse seqOf: a_n = n! * [X^n] f. Round-trips with egf_coeffs."""
    return [Fraction(factorial(n)) * coeffs[n] for n in range(len(coeffs))]
