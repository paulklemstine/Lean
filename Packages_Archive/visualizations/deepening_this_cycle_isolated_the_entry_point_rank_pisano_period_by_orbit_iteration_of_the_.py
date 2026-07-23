from math import gcd
from typing import Tuple

def pisano_period_naive(m: int) -> int:
    """Pisano period pi(m) as the order of the Fibonacci shift Q(a,b)=(b,a+b):
    the least k>0 returning the orbit of (0,1) to (0,1). O(pi(m)) ops."""
    if m == 1:
        return 1
    a, b = 0, 1
    for k in range(1, 6 * m + 1):
        a, b = b % m, (a + b) % m
        if a == 0 and b == 1:
            return k
    raise RuntimeError("unreachable: pi(m) <= 6m for all m")
