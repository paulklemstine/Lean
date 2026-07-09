from __future__ import annotations
from math import comb
from typing import Dict, List, Tuple


def narayana(n: int, k: int) -> int:
    """Narayana number N(n, k) = binom(n, k) * binom(n, k-1) / n."""
    if n == 0:
        return 1 if k == 0 else 0
    if k < 1 or k > n:
        return 0
    return comb(n, k) * comb(n, k - 1) // n


def catalan(n: int) -> int:
    """Catalan number C_n = binom(2n, n) / (n + 1)."""
    return comb(2 * n, n) // (n + 1)


def endpoint_valley_distribution(n: int) -> List[int]:
    """Return [N(n, k+1) for k in range(0, n)], the predicted number of Dyck
    lower endpoints of semilength n with exactly k valleys.  The list sums to
    the Catalan number C_n by the Narayana refinement of the Catalan numbers.
    """
    return [narayana(n, k + 1) for k in range(0, n)]
