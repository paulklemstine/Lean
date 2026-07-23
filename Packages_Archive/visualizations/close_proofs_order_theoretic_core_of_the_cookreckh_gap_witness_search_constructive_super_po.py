from __future__ import annotations
from typing import Optional


def gap_witness(c: int, k: int, n_search: int = 500) -> Optional[int]:
    """Least n >= 2 realizing the Gap Lemma (Lemma 6.2):
        (2 ** (n ** k) + 2) ** c < 2 ** (n ** (k + 1)),   for k >= 1.

    Mathematical foundation: rung k+1 of the power ladder 2^(n^k) eventually
    outruns every degree-c polynomial inflation of rung k, because the exponent
    jumps from n^k to n^(k+1) = n * n^k. Theory guarantees n = max(2, c+1).
    Complexity: O(n_search) big-integer power comparisons (exponents grow fast).
    """
    if k < 1:
        return None
    for n in range(2, n_search + 1):
        if (2 ** (n ** k) + 2) ** c < 2 ** (n ** (k + 1)):
            return n
    return None
