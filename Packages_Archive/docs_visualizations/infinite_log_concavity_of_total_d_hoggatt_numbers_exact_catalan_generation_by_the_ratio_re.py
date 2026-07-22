from fractions import Fraction
from typing import List

def catalan_ratio(length: int) -> List[Fraction]:
    """Generate Catalan numbers by the two-term ratio recurrence
    C_0 = 1,  C_{n+1} = 2(2n+1)/(n+2) * C_n, in exact rational arithmetic.

    Equivalent to C_n = binom(2n, n)/(n+1) but avoids large binomials and
    keeps every intermediate exact. Complexity O(N) big-integer operations.
    """
    out: List[Fraction] = [Fraction(1)]
    for n in range(length - 1):
        out.append(Fraction(2 * (2 * n + 1), n + 2) * out[-1])
    return out
