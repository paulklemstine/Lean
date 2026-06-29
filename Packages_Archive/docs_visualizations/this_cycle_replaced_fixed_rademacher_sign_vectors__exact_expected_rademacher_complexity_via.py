from __future__ import annotations
from itertools import product
from typing import Sequence

Hypothesis = Sequence[float]
SignVector = Sequence[int]


def rademacher_correlation(sigma: SignVector, h: Hypothesis) -> float:
    """corr(sigma, h) = (1/n) sum_i sigma_i h_i."""
    n = len(h)
    return sum(s * x for s, x in zip(sigma, h)) / n if n else 0.0


def expected_rademacher(n: int, H: Sequence[Hypothesis]) -> float:
    """Exact R_n(H) by enumerating all 2**n sign patterns.

    Time:  Theta(2**n * |H| * n).   Space: Theta(n) (streaming over patterns).
    """
    assert len(H) > 0, "class must be nonempty"
    total = 0.0
    count = 0
    for sigma in product((-1, 1), repeat=n):
        total += max(rademacher_correlation(sigma, h) for h in H)
        count += 1
    return total / count  # count == 2**n
