from fractions import Fraction
from math import comb

def sum_badcount(n: int) -> int:
    """Exact incidence identity: sum over all colorings of the number of
    monochromatic 4-sets equals C(n,4) * 2^(C(n,3) - 3)  (n >= 4)."""
    return comb(n, 4) * 2 ** (comb(n, 3) - 3)

def expected_badcount(n: int) -> Fraction:
    """Average monochromatic-4-set count over all 2^C(n,3) colorings = C(n,4)/8."""
    return Fraction(sum_badcount(n), 2 ** comb(n, 3))
