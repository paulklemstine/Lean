from __future__ import annotations
from math import gcd

def fib_mod(k: int, m: int) -> int:
    """F(k) mod m with F(0)=0, F(1)=1, computed in O(k) with bounded residues."""
    a, b = 0 % m, 1 % m
    for _ in range(k):
        a, b = b, (a + b) % m
    return a

def rank_of_apparition(m: int) -> int:
    """Least k > 0 with m | F(k). Iterates over the Pisano period; O(period(m))."""
    if m < 1:
        raise ValueError("modulus must be >= 1")
    if m == 1:
        return 1
    a, b = 0, 1
    k = 0
    while True:
        if k > 0 and a % m == 0:
            return k
        a, b = b % m, (a + b) % m
        k += 1

def lcm(a: int, b: int) -> int:
    return 0 if a == 0 or b == 0 else a // gcd(a, b) * b

def reconvergence_step(a: int, b: int) -> int:
    """Step of the line L(a) cap L(b), via the Join Law:
       alpha(lcm(a,b)) = lcm(alpha a, alpha b)."""
    return lcm(rank_of_apparition(a), rank_of_apparition(b))
