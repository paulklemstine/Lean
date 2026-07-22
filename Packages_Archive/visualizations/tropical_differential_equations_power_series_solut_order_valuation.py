from fractions import Fraction
from typing import List, Union

INF = float("inf")

def order(coeffs: List[Union[int, Fraction]]) -> Union[int, float]:
    """Order (valuation) of a power series: index of first nonzero coefficient."""
    for i, c in enumerate(coeffs):
        if c != 0:
            return i
    return INF  # zero series (up to the available precision)
