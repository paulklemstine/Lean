from __future__ import annotations
from typing import List

def gcd(a: int, b: int) -> int:
    while b:
        a, b = b, a % b
    return abs(a)

def count_representations(n: int) -> int:
    """#{1-dim complex Galois reps of Gal(Q(zeta_n)/Q)} = phi(n)
    (card_galois_reps_eq_totient). For prime p this is p-1."""
    return sum(1 for a in range(1, n + 1) if gcd(a, n) == 1)
