from math import gcd
from typing import List, Optional

def units_mod(n: int) -> List[int]:
    return [k for k in range(1, n + 1) if gcd(k, n) == 1]

def multiplicative_order(a: int, n: int) -> int:
    order, cur = 1, a % n
    while cur != 1:
        cur = (cur * a) % n
        order += 1
    return order

def primitive_root(n: int) -> Optional[int]:
    """A generator of (Z/nZ)^x (== Gal(Q(zeta_n)/Q)) if one exists, else None.
    For prime n it always exists; it is a cyclic generator of order n-1."""
    from math import prod
    target = len(units_mod(n))
    for a in units_mod(n):
        if multiplicative_order(a, n) == target:
            return a
    return None
