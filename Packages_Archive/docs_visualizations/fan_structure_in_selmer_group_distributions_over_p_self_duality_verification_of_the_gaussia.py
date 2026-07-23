from __future__ import annotations
from typing import List


def verify_self_duality(q: int, n: int) -> bool:
    """Verify [n,k]_q = [n,n-k]_q across the whole fan for given q, n.

    Builds the fan once (O(n^2)) then checks the reflection k <-> n-k.
    """
    row: List[int] = [1]
    for m in range(1, n + 1):
        new: List[int] = [1] + [0] * m
        for j in range(1, m + 1):
            up = row[j] if j < len(row) else 0
            new[j] = row[j - 1] + (q ** j) * up
        row = new
    return all(row[k] == row[n - k] for k in range(n + 1))
