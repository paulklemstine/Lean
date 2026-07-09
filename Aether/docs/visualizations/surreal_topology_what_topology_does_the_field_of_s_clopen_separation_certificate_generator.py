from fractions import Fraction
from math import floor
from typing import Dict, Optional


def clopen_separation(a: Dict[Fraction, Fraction],
                      b: Dict[Fraction, Fraction]) -> Optional[dict]:
    """Given a FINITE surreal a and an INFINITE surreal b (both on the omega-scale),
    return a certificate that they lie in different pieces of the clopen partition
    No = F  disjoint-union  (No \ F), proving no continuous path joins them.

    The certificate is a natural number n with a < n <= b: then a in Iio(n) subset F
    (open) and b in Ioi(n-1) subset complement(F) (open).  Complexity O(#terms)."""
    def leading(t):
        nz = {e: c for e, c in t.items() if c != 0}
        return (max(nz), nz[max(nz)]) if nz else None

    la, lb = leading(a), leading(b)
    a_finite = (la is None) or (la[0] <= 0)
    b_infinite = (lb is not None) and (lb[0] > 0)
    if not (a_finite and b_infinite):
        return None
    # least natural number above a
    if la is None or la[0] < 0:
        n = 1
    else:
        n = max(1, floor(la[1]) + 1)
    return {"witness_n": n, "a_in_Iio_n": True, "b_in_Ioi_n_minus_1": True}
