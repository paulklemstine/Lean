from math import comb
from typing import List

def ball_volume(n: int, q: int, r: int) -> int:
    """Exact Hamming-ball volume |B_r| = sum_{i<=r} C(n,i)(q-1)^i in O(r) ops."""
    total: int = 0
    binom: int = 1  # C(n, 0)
    power: int = 1  # (q-1)^0
    for i in range(r + 1):
        total += binom * power
        binom = binom * (n - i) // (i + 1)   # rolling C(n,i+1)
        power = power * (q - 1)               # rolling (q-1)^(i+1)
    return total

def sphere_card(n: int, q: int, r: int) -> int:
    """Exact Hamming-sphere count C(n,r)(q-1)^r."""
    return comb(n, r) * (q - 1) ** r
