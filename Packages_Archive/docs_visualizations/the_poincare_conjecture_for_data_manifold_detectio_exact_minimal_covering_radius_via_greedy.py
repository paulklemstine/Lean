from __future__ import annotations
import math

def coverable_1d(m: int, n: int, r: int) -> bool:
    """1-D grid {0,...,m-1} is r-coverable with <= n samples iff ceil(m/(2r+1)) <= n."""
    return math.ceil(m / (2 * r + 1)) <= n

def min_radius_1d(m: int, n: int) -> int:
    """Smallest r with an r-cover of {0,...,m-1} using at most n landmarks."""
    if n <= 0:
        raise ValueError("need at least one sample")
    r = 0
    while not coverable_1d(m, n, r):
        r += 1
    return r
