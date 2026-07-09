from math import gcd
from typing import List, Tuple

def extended_gcd(a: int, b: int) -> Tuple[int, int, int]:
    """Return (g, u, v) with u*a + v*b = g = gcd(a, b)."""
    old_r, r = a, b
    old_u, u = 1, 0
    old_v, v = 0, 1
    while r != 0:
        q = old_r // r
        old_r, r = r, old_r - q * r
        old_u, u = u, old_u - q * u
        old_v, v = v, old_v - q * v
    return old_r, old_u, old_v

def glue_coprime(moduli: List[int]) -> int:
    """Given pairwise-coprime moduli each dividing some fixed x, return the
    product modulus that must also divide x (Chinese Remainder gluing)."""
    prod = 1
    for m in moduli:
        g, _, _ = extended_gcd(prod, m)
        assert g == 1, f"moduli not coprime: {prod} and {m}"
        prod *= m
    return prod

if __name__ == "__main__":
    # 2, 3, 5 each divide a^5 - a; glue to 30.
    assert glue_coprime([2, 3, 5]) == 30
    print("Glued modulus:", glue_coprime([2, 3, 5]))
