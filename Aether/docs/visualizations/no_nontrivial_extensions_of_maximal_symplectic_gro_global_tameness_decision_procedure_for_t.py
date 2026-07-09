from math import gcd
from typing import List

MUKAI_ORDERS: List[int] = [960, 384, 288, 192, 192, 72, 72, 48, 168, 360, 120]

def is_prime(n: int) -> bool:
    if n < 2:
        return False
    d = 2
    while d * d <= n:
        if n % d == 0:
            return False
        d += 1
    return True

def aut_order_tame(p: int, sympl_order: int, index: int, bound: int = 7) -> bool:
    assert is_prime(p), 'p must be prime'
    assert sympl_order in MUKAI_ORDERS, 'symplectic order must be a Mukai order'
    assert p > bound, 'arithmetic tameness needs p > 7'
    assert gcd(p, index) == 1, 'non-symplectic index must be coprime to p'
    return (sympl_order * index) % p != 0

if __name__ == '__main__':
    print(aut_order_tame(13, 960, 5))  # True
