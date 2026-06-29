from math import gcd
from typing import Optional


def is_prime(n: int) -> bool:
    """Deterministic trial-division primality test."""
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


def mersenne_entry_point(b: int, p: int) -> Optional[int]:
    """Compute entryPoint(b^n - 1, p) = orderOf(b mod p) for prime p with p not dividing b.

    By the Apparition-Order Bridge the rank of apparition equals the
    multiplicative order of b in the residue field Z/pZ, so we never form the
    exploding integers b^n - 1: we iterate the power on the finite clock mod p.
    By Fermat descent the loop runs at most p - 1 times.
    """
    if not is_prime(p) or b % p == 0:
        return None
    x = b % p
    acc = x
    k = 1
    while acc != 1 % p:
        acc = (acc * x) % p
        k += 1
    return k  # equals the order of b mod p, hence the entry point
