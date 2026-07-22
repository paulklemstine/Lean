from math import gcd
from typing import List, Tuple


def generate_orbit(p: int, b: int) -> Tuple[List[int], List[int]]:
    """Generate one full period of the remainder orbit and digit sequence
    of 1/p in base b via the long-division recurrence.

    Requires gcd(p, b) = 1 so that the orbit is purely periodic. Returns
    (remainders, digits), each of length l = ord_p(b) for prime p.
    """
    if gcd(p, b) != 1:
        raise ValueError("require gcd(p, b) = 1")
    r: int = 1
    remainders: List[int] = []
    digits: List[int] = []
    while True:
        remainders.append(r)
        digits.append((b * r) // p)
        r = (b * r) % p
        if r == 1:
            break
    return remainders, digits
