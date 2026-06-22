from __future__ import annotations
from itertools import product
from typing import Sequence

SignVector = Sequence[int]
Hypothesis = Sequence[float]


def rademacher_correlation(sigma: SignVector, h: Hypothesis) -> float:
    n = len(h)
    return sum(s * x for s, x in zip(sigma, h)) / n if n else 0.0


def duality_sum_via_involution(n: int, h: Hypothesis) -> float:
    """Verify Theorem 4.2 by pairing each pattern with its sign-flip.

    Enumerates only the 2**(n-1) patterns whose first sign is -1, pairs each
    with its full complement (the sign-flip involution), and sums the two
    correlations -- which cancel exactly.  The grand total is therefore 0.

    Time:  Theta(2**(n-1) * n).   Space: Theta(n).
    """
    if n == 0:
        return 0.0
    total = 0.0
    for tail in product((-1, 1), repeat=n - 1):
        sigma = (-1,) + tuple(tail)
        flipped = tuple(-s for s in sigma)
        total += rademacher_correlation(sigma, h) + rademacher_correlation(flipped, h)
    return total
