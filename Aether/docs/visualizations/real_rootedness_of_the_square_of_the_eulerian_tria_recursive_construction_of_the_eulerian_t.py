from functools import lru_cache
from typing import List

@lru_cache(maxsize=None)
def eulerian(n: int, k: int) -> int:
    """Eulerian number A(n,k) via the triangular recurrence, memoized: O(n*k) work."""
    if k < 0 or k >= max(n, 1):
        return 0
    if n == 0:
        return 1 if k == 0 else 0
    if k == 0:
        return 1
    return (k + 1) * eulerian(n - 1, k) + (n - k) * eulerian(n - 1, k - 1)

def eulerian_triangle(N: int) -> List[List[int]]:
    return [[eulerian(n, k) for k in range(max(n, 1))] for n in range(N + 1)]
