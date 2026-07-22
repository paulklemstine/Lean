from __future__ import annotations
import math

def catalan(n: int) -> int:
    return math.comb(2 * n, n) // (n + 1)

def catalan_discriminant_witness(n: int) -> tuple[int, int, int]:
    """Return (A, gap, C_{n+1}^2) certifying strict log-convexity at n via
        A * (C_n C_{n+2} - C_{n+1}^2) = gap * C_{n+1}^2,
    where A = (2n+1)(n+3) > 0 and gap = 3 > 0.  Since the right side is
    strictly positive, C_n C_{n+2} > C_{n+1}^2."""
    A = (2 * n + 1) * (n + 3)
    gap = (n + 2) * (2 * n + 3) - A            # provably 3
    c1sq = catalan(n + 1) ** 2
    # sanity check of the identity
    assert A * (catalan(n) * catalan(n + 2) - c1sq) == gap * c1sq
    return A, gap, c1sq
