from __future__ import annotations
from typing import List


def path_matching_polynomial(n: int) -> List[float]:
    """Return coefficients of the matching polynomial mu(P_n) of the path on n
    vertices, highest degree first, using the edge-deletion recurrence
        mu(P_0) = 1, mu(P_1) = x, mu(P_{k}) = x*mu(P_{k-1}) - mu(P_{k-2}).
    Complexity: O(n^2) arithmetic operations, O(n) memory.
    """
    if n == 0:
        return [1.0]
    if n == 1:
        return [1.0, 0.0]
    prev2: List[float] = [1.0]        # mu(P_0)
    prev1: List[float] = [1.0, 0.0]   # mu(P_1)
    for _ in range(2, n + 1):
        cur = prev1 + [0.0]           # x * prev1
        offset = len(cur) - len(prev2)
        for i, c in enumerate(prev2):
            cur[offset + i] -= c      # subtract prev2
        prev2, prev1 = prev1, cur
    return prev1
