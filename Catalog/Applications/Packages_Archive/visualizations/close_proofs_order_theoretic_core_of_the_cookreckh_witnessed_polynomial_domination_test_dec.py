from __future__ import annotations
from typing import Callable, Optional


def witnessed_domination(a: Callable[[int], int], b: Callable[[int], int],
                         n_max: int = 30, k_max: int = 12) -> Optional[int]:
    """Return least exponent k certifying  sysOfSize(a) simulates sysOfSize(b),
    i.e.  a(n) + 1 <= (b(n) + 2) ** k  for all sampled n; None if none found.

    Mathematical foundation: the Domination Law (Theorem 5.2) states that
    simulation between size-indexed systems is exactly polynomial domination of
    size functions. Complexity: O(k_max * n_max) big-integer comparisons.
    """
    for k in range(k_max + 1):
        if all(a(n) + 1 <= (b(n) + 2) ** k for n in range(n_max + 1)):
            return k
    return None
