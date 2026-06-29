from __future__ import annotations
from math import gcd

def fixed_by_rotation(p: int, k: int) -> int:
    return 2 ** gcd(k, p)

def necklace_count(p: int) -> int:
    return sum(fixed_by_rotation(p, k) for k in range(p)) // p
