from math import gcd
from typing import List, Tuple


def entry(m: int) -> int:
    """Rank of apparition: least k > 0 with m | F(k). Uses O(entry(m)) steps."""
    if m < 1:
        raise ValueError("m >= 1 required")
    if m == 1:
        return 1
    a, b = 0, 1            # a = F(0) mod m, b = F(1) mod m
    k = 1
    while b % m != 0:
        a, b = b, (a + b) % m
        k += 1
    return k
