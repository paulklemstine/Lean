from functools import lru_cache
from typing import List, Tuple

def _poly_add(a: Tuple[int, ...], b: Tuple[int, ...]) -> Tuple[int, ...]:
    out = [0] * max(len(a), len(b))
    for i, c in enumerate(a):
        out[i] += c
    for i, c in enumerate(b):
        out[i] += c
    return tuple(out)

@lru_cache(maxsize=None)
def q_binomial(m: int, n: int) -> Tuple[int, ...]:
    """[m+n choose n]_q as a coefficient tuple via the q-Pascal recurrence."""
    if m == 0 or n == 0:
        return (1,)
    left = q_binomial(m, n - 1)
    right = (0,) * n + q_binomial(m - 1, n)   # multiply by q^n
    return _poly_add(left, right)

def q_binomial_at_one(m: int, n: int) -> int:
    """Specialization at q = 1 equals the ordinary binomial C(m+n, n)."""
    return sum(q_binomial(m, n))
