from __future__ import annotations
from math import isqrt

def is_anti_fib(m: int) -> bool:
    """Return True iff m occurs in the anti-Fibonacci sequence.
    Uses the spectrum theorem: m in range(A) iff 8m-7 is a perfect square.
    O(1) arithmetic plus one integer square root."""
    if m < 1:
        return False
    s = 8 * m - 7
    r = isqrt(s)
    return r * r == s
