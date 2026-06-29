from __future__ import annotations
from typing import Dict, Optional


def factorize(n: int) -> Dict[int, int]:
    """Prime factorization of n > 0 as {prime: exponent}."""
    factors: Dict[int, int] = {}
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors[d] = factors.get(d, 0) + 1
            n //= d
        d += 1 if d == 2 else 2
    if n > 1:
        factors[n] = factors.get(n, 0) + 1
    return factors


def gcd(a: int, b: int) -> int:
    while b:
        a, b = b, a % b
    return abs(a)


def mult_order(b: int, p: int) -> Optional[int]:
    """
    Multiplicative order of b modulo the prime p, computed by Fermat
    descent. By the Apparition-Order Bridge this equals the entry point
    (rank of apparition) of p in the sequence b**n - 1.

    Since order(b) | p - 1 (Lagrange / Fermat), we start from p - 1 and,
    for each prime q dividing p - 1, strip factors q while b**(e/q) == 1.
    """
    b %= p
    if gcd(b, p) != 1:
        return None  # b not a unit modulo p
    order = p - 1
    for q in factorize(p - 1):
        while order % q == 0 and pow(b, order // q, p) == 1:
            order //= q
    return order
