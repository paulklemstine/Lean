from math import gcd
from typing import Optional

def multiplicative_order(a: int, m: int) -> Optional[int]:
    """Least k>0 with a^k = 1 (mod m); equals the Mersenne rank of apparition."""
    if m <= 1 or gcd(a, m) != 1:
        return None
    x, k = a % m, 1
    while x != 1:
        x = (x * a) % m
        k += 1
        if k > m:
            return None
    return k
