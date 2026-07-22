from math import comb
from typing import Callable

def s2(n: int) -> int:
    """Binary sum-of-digits (popcount)."""
    return bin(n).count("1")

def cusick_count(t: int, N: int) -> int:
    """cusickCount(t, N) = #{ n < N : s2(n) <= s2(n+t) } by direct enumeration.
    Complexity: O(N * log N) bit operations."""
    return sum(1 for n in range(N) if s2(n) <= s2(n + t))
