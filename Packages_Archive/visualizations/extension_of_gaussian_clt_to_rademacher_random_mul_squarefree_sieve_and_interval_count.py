from typing import List


def squarefree_sieve(limit: int) -> List[bool]:
    """Return sf[0..limit] with sf[n] True iff n is squarefree.

    Marks every multiple of p^2 (for p^2 <= limit) as non-squarefree.
    Time O(limit log log limit); space O(limit).
    """
    sf: List[bool] = [True] * (limit + 1)
    sf[0] = False
    d = 2
    while d * d <= limit:
        step = d * d
        for k in range(step, limit + 1, step):
            sf[k] = False
        d += 1
    return sf


def squarefree_count(a: int, b: int) -> int:
    """Number of squarefree integers in [a, b]."""
    sf = squarefree_sieve(b)
    return sum(1 for n in range(a, b + 1) if sf[n])
