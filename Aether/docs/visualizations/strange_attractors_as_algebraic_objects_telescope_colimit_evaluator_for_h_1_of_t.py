from fractions import Fraction
from typing import Tuple

def colim_eval(level: int, value: int) -> Fraction:
    """Element (level, value) of colim(Z --x2--> ...) as value/2^level."""
    return Fraction(value, 2 ** level)

def colim_equal(a: Tuple[int, int], b: Tuple[int, int]) -> bool:
    (n1, m1), (n2, m2) = a, b
    return m1 * (2 ** n2) == m2 * (2 ** n1)
