from math import gcd
from typing import Tuple

def entry_point(m: int) -> int:
    """Rank of apparition: least k > 0 with m | F(k).

    Iterates the residue recurrence (a, b) = (F(k) mod m, F(k+1) mod m).
    Terminates by the existence theorem; the Pisano period (and hence the
    search) is bounded by m*m. Each step is O(1) machine-word arithmetic,
    so overall complexity is O(m^2) time and O(1) space.
    """
    if m <= 0:
        raise ValueError("entry_point requires a positive modulus")
    if m == 1:
        return 1
    a, b = 0, 1  # (F(0) mod m, F(1) mod m)
    k = 0
    while True:
        k += 1
        a, b = b, (a + b) % m  # advance to (F(k) mod m, F(k+1) mod m)
        if a == 0:
            return k
