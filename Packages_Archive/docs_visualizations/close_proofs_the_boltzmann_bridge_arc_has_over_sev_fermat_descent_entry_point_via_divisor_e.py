from typing import List, Optional


def divisors(m: int) -> List[int]:
    """All positive divisors of m, ascending."""
    small, large = [], []
    d = 1
    while d * d <= m:
        if m % d == 0:
            small.append(d)
            if d != m // d:
                large.append(m // d)
        d += 1
    return small + large[::-1]


def mersenne_entry_point_fast(b: int, p: int) -> Optional[int]:
    """Entry point of p in b^n - 1 via Fermat descent: the order divides p - 1,
    so it is the least divisor d of p - 1 with (b mod p)^d = 1 (mod p).

    Each test is a modular exponentiation in O(log d) multiplications, so the
    whole routine costs O(d(p-1) * log p) rather than O(order) naive steps.
    """
    if p < 2 or b % p == 0:
        return None
    x = b % p
    for d in divisors(p - 1):          # ascending; first hit is the order
        if pow(x, d, p) == 1 % p:
            return d
    return None
