from __future__ import annotations


def bottom_degree_parity(n: int, r1: int, r2: int) -> int:
    """Parity (0=even, 1=odd) of the bottom degree b(F,n) in O(1).

    Uses the two parity laws:
        floor(n^2/4) is odd  <=>  n % 4 == 2
        n(n-1)/2     is odd  <=>  n % 4 in (2, 3)
    so that:
        n % 4 in (0, 1):  b is even           -> 0
        n % 4 == 2:       b ≡ r1 + r2 (mod 2)
        n % 4 == 3:       b ≡ r2      (mod 2)
    """
    m = n % 4
    if m in (0, 1):
        return 0
    if m == 2:
        return (r1 + r2) % 2
    return r2 % 2  # m == 3
