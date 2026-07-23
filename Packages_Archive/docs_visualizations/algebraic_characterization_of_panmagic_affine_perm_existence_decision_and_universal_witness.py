from math import gcd
from typing import Optional, Tuple

def panmagic_witness(n: int) -> Optional[Tuple[int, int]]:
    """Decide existence of a panmagic affine permutation of Z_n and return a
    certified witness (a, b), or None if none exists.

    Existence holds iff gcd(n, 6) == 1. In that case the universal witness
    a = 2, b = 0 works, because then a-1 = 1, a = 2, a+1 = 3 are all units
    of Z_n. Complexity: O(log n) for a single gcd.
    """
    if gcd(n, 6) == 1:
        return (2 % n, 0)
    return None
