from __future__ import annotations
from math import gcd
from typing import List, Optional, Tuple


def lcm(a: int, b: int) -> int:
    return a * b // gcd(a, b)


def is_prime(n: int) -> bool:
    if n < 2:
        return False
    if n % 2 == 0:
        return n == 2
    d = 3
    while d * d <= n:
        if n % d == 0:
            return False
        d += 2
    return True


def verify_certificate(k: int, cert: List[Tuple[int, int, int]]) -> bool:
    """Sound verifier for a Sierpinski covering certificate.

    cert is a list of (residue a, modulus m, prime p). Returns True iff:
      (i) each p is prime, (ii) p | k*2^a + 1, (iii) 2^m = 1 (mod p),
      (iv) the classes cover every residue modulo L = lcm of moduli.
    A True verdict certifies (via certificate_gives_divisor and
    covering_finite_verification) that every k*2^n + 1 has a fixed small divisor.
    """
    L = 1
    for (_a, m, _p) in cert:
        L = lcm(L, m)
    for (a, m, p) in cert:
        if not is_prime(p):
            return False
        if (k * pow(2, a, p) + 1) % p != 0:
            return False
        if pow(2, m, p) != 1:
            return False
    for n in range(L):
        if not any(n % m == a and (k * pow(2, n, p) + 1) % p == 0
                   for (a, m, p) in cert):
            return False
    return True


def covering_witness(k: int, cert: List[Tuple[int, int, int]], n: int) -> Optional[int]:
    """Return the covering prime for exponent n (mirrors certificate_gives_divisor)."""
    for (a, m, p) in cert:
        if n % m == a and (k * pow(2, n, p) + 1) % p == 0:
            return p
    return None
