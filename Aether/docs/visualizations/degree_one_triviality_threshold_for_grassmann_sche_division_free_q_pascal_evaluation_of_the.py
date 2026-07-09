from functools import lru_cache
from typing import List


@lru_cache(maxsize=None)
def q_binom(q: int, n: int, k: int) -> int:
    """Gaussian binomial [n,k]_q via the division-free q-Pascal recurrence."""
    if k < 0 or k > n:
        return 0
    if k == 0:
        return 1
    if n == 0:
        return 0
    return q_binom(q, n - 1, k - 1) + (q ** k) * q_binom(q, n - 1, k)


def q_pascal_row(q: int, n: int) -> List[int]:
    """Return the full row [[n,0]_q, ..., [n,n]_q] of the q-Pascal triangle."""
    return [q_binom(q, n, k) for k in range(n + 1)]
