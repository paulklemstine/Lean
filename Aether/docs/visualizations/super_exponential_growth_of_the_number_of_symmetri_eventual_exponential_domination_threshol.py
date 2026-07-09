from __future__ import annotations
from typing import Callable


def eventual_domination_threshold(
    f: Callable[[int], int], c: int, search_limit: int = 2000
) -> int | None:
    """Smallest N with c**n < f(n) for all N <= n <= search_limit, else None.

    Witnesses the existential N in SuperExp f := forall c, exists N,
    forall n>=N, c^n < f n. Returns None when no stable crossover exists
    (evidence the sequence is NOT super-exponential for this base c).
    """
    last_fail: int = -1
    for k in range(search_limit + 1):
        if not (c ** k < f(k)):
            last_fail = k
    return None if last_fail == search_limit else last_fail + 1
