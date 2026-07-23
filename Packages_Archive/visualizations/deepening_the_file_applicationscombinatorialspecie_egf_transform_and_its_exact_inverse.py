from fractions import Fraction
from math import factorial
from typing import List, Sequence

def egf(a: Sequence[Fraction]) -> List[Fraction]:
    return [Fraction(a[n]) / factorial(n) for n in range(len(a))]

def seq_of(c: Sequence[Fraction]) -> List[Fraction]:
    return [factorial(n) * Fraction(c[n]) for n in range(len(c))]
