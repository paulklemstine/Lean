from fractions import Fraction
from typing import Optional, Tuple

def dyadic_certificate(q: Fraction) -> Optional[Tuple[int, int]]:
    """Return (k, m) with (m:Q) = 2^k * q and m in Z, else None."""
    b = q.denominator
    k = 0
    while b % 2 == 0:
        b //= 2
        k += 1
    if b != 1:
        return None
    m = q * (2 ** k)
    return k, int(m)
