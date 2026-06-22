from math import gcd
from typing import Callable, List

def joint_apparition_count(a: Callable[[int], int], primes: List[int], N: int) -> int:
    """Number of n in 1..N at which ALL given primes divide a(n).
    By the finite-family join law this equals floor(N / L) where L is the lcm of
    the primes' entry points -- computed with one entry-point scan per prime and
    a single integer division, independent of N."""
    def lcm(x: int, y: int) -> int:
        return 0 if x == 0 or y == 0 else x // gcd(x, y) * y

    def entry(p: int) -> int:
        k = 1
        while a(k) % p != 0:
            k += 1
        return k

    L = 1
    for p in primes:
        L = lcm(L, entry(p))
    return N // L if L else 0
