from fractions import Fraction
from typing import List

def pipeline_lipschitz(constants: List[Fraction]) -> Fraction:
    C: Fraction = Fraction(1)
    for c in constants:
        C *= Fraction(c)
    return C

def pipeline_is_nonexpansive(constants: List[Fraction]) -> bool:
    return all(Fraction(c) <= 1 for c in constants)
