from math import gcd
from typing import List


def stern_by_bits(n: int) -> int:
    """Evaluate s(n) by reading the binary digits of n from most to least
    significant, maintaining the running pair (s(m), s(m+1)) as bits are
    appended. Runs in O(log n) integer additions."""
    a, b = 0, 1  # (s(0), s(1))
    for bit in bin(n)[2:]:
        if bit == '0':
            a, b = a, a + b       # descend to even child
        else:
            a, b = a + b, b       # descend to odd child
    return a
