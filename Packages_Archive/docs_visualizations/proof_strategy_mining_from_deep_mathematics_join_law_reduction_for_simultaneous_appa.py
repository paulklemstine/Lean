from math import gcd
from functools import reduce
from typing import Callable, List, Optional

def joint_apparition_modulus(u: Callable[[int], int], primes: List[int]) -> Optional[int]:
    """Return L = lcm of ranks so that  (all p in primes divide u_n)  <=>  L | n.

    Implements the join law / simultaneous-apparition reduction: the common
    apparition set of a finite family of primes is itself an apparition class,
    governed by the lcm of their individual ranks. Returns None if some prime
    never appears.
    """
    def rank(p: int) -> Optional[int]:
        for k in range(1, 2001):
            if u(k) % p == 0:
                return k
        return None

    ranks = [rank(p) for p in primes]
    if any(r is None for r in ranks):
        return None
    return reduce(lambda a, b: a * b // gcd(a, b), ranks, 1)
