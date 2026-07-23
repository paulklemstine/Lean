from math import gcd, comb
from typing import Optional


def interior_row_gcd(k: int) -> int:
    """Return F(k) = gcd_{1<=i<=k} C(k+1, i), the interior Pascal-row gcd."""
    if k < 1:
        raise ValueError("k must be >= 1")
    g = 0
    c = 1  # C(k+1, 0)
    n = k + 1
    for i in range(1, k + 1):
        c = c * (n - i + 1) // i  # exact: now c == C(n, i)
        g = gcd(g, c)
        if g == 1:
            return 1
    return g


def prime_power_base(n: int) -> Optional[int]:
    """If n = p^a (p prime, a>=1) return p; otherwise None (1 is not a prime power)."""
    if n < 2:
        return None
    d = 2
    p = None
    while d * d <= n:
        if n % d == 0:
            p = d
            break
        d += 1
    if p is None:
        return n
    m = n
    while m % p == 0:
        m //= p
    return p if m == 1 else None


def predicted_F(k: int) -> int:
    """Predict F(k) from the prime-power criterion (no row summation)."""
    base = prime_power_base(k + 1)
    return base if base is not None else 1
