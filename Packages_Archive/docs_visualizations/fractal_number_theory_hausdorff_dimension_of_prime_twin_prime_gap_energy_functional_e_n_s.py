from __future__ import annotations
import math

def prime_gap_energy(bound: int, s: float) -> float:
    """Prime-gap energy E(bound, s) = sum over twin pairs (k, k+2) with
    k < bound of |1/log k - 1/log(k+2)|^s. The critical exponent in s is a
    conjectural invariant of the twin-prime sub-dust's box dimension."""
    def is_prime(n: int) -> bool:
        if n < 2: return False
        if n % 2 == 0: return n == 2
        d = 3
        while d * d <= n:
            if n % d == 0: return False
            d += 2
        return True
    total = 0.0
    for k in range(3, bound):
        if is_prime(k) and is_prime(k + 2):
            total += abs(1 / math.log(k) - 1 / math.log(k + 2)) ** s
    return total
