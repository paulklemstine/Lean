from math import gcd
from typing import List

def mult_order(a: int, m: int) -> int:
    """Multiplicative order of a unit a modulo m."""
    k, cur = 1, a % m
    while cur != 1:
        cur = (cur * a) % m; k += 1
    return k

def primitive_root(p: int) -> int:
    """A generator of the cyclic group (Z/pZ)^x."""
    for g in range(2, p):
        if mult_order(g, p) == p - 1:
            return g
    return 1  # p == 2

def korselt_extract(n: int, p: int) -> bool:
    """Certify (p-1)|(n-1) via the three-movement argument."""
    # Movement 1: reduction (Z/nZ)^x -> (Z/pZ)^x is surjective
    images = {u % p for u in range(1, n) if gcd(u, n) == 1}
    assert images == set(range(1, p)), 'reduction not surjective'
    # Movement 3: a primitive root has order exactly p-1
    g: int = primitive_root(p)
    order_g: int = mult_order(g, p) if p > 2 else 1
    assert order_g == p - 1
    # Conclusion
    return (n - 1) % (p - 1) == 0
