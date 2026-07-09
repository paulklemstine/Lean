from __future__ import annotations
from typing import List

def gcd(a: int, b: int) -> int:
    while b:
        a, b = b, a % b
    return abs(a)

def artin_symbol(a: int, n: int) -> int:
    """Artin symbol of the automorphism zeta_n -> zeta_n^a : the residue a mod n.
    Requires gcd(a, n) == 1 (a is a unit). Composition multiplies symbols mod n."""
    if gcd(a, n) != 1:
        raise ValueError("a must be coprime to n to define an automorphism")
    return a % n

def compose_symbols(a: int, b: int, n: int) -> int:
    """Artin symbol of sigma_a o sigma_b is a*b mod n (group law of (Z/nZ)^*)."""
    return artin_symbol((a * b) % n, n)
