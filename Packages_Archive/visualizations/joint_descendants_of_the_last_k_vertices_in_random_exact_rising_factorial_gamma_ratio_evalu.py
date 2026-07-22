from fractions import Fraction
from typing import Union

Number = Union[float, Fraction]


def gamma_ratio_integer_shift(x: Number, m: int) -> Number:
    """Return Gamma(x+m)/Gamma(x) = prod_{i=0}^{m-1} (x+i) via the
    rising-factorial identity. Exact for Fraction inputs, O(m) multiplications."""
    prod: Number = Fraction(1) if isinstance(x, Fraction) else 1.0
    for i in range(m):
        prod *= (x + i)
    return prod
