from __future__ import annotations
from typing import List


def divisors(n: int) -> List[int]:
    """Sorted positive divisors of n."""
    ds: List[int] = []
    d = 1
    while d * d <= n:
        if n % d == 0:
            ds.append(d)
            if d != n // d:
                ds.append(n // d)
        d += 1
    return sorted(ds)


def entry_point_via_bridge(b: int, p: int) -> int:
    """Entry point of prime p in b^n - 1, computed locally via the bridge.

    Preconditions: p is prime and p does not divide b.
    Returns the least k > 0 with p | b^k - 1, which equals ord_p(b) and
    divides p - 1 (Fermat descent).
    """
    assert b % p != 0, "p must not divide b"
    n = p - 1
    for d in divisors(n):          # Fermat descent: answer divides p - 1
        if pow(b, d, p) == 1:      # modular exponentiation, stays bounded by p
            return d
    return n                       # unreachable: Fermat guarantees a divisor works
