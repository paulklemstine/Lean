from fractions import Fraction
from math import comb


def expected_empty_uniform(n: int, j: int) -> Fraction:
    """Balanced-distribution value in O(N) time:

        E_unif[U_j^N] = N * sum_{s=0}^{N-1} (-1)^s C(N-1, s) / (1+s)^j
    """
    return Fraction(n) * sum(
        (Fraction((-1) ** s * comb(n - 1, s), (1 + s) ** j) for s in range(n)),
        Fraction(0),
    )
