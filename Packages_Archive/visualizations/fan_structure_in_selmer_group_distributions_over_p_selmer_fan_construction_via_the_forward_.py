from __future__ import annotations
from typing import List


def selmer_fan(q: int, n: int) -> List[int]:
    """Compute the full Selmer fan [n,0]_q..[n,n]_q in O(n^2) big-int ops.

    Uses the forward q-Pascal recurrence
        [m+1,j+1]_q = [m,j]_q + q^(j+1) * [m,j+1]_q
    building each row from the previous one.
    """
    row: List[int] = [1]
    for m in range(1, n + 1):
        new: List[int] = [1] + [0] * m
        for j in range(1, m + 1):
            left = row[j - 1]
            up = row[j] if j < len(row) else 0
            new[j] = left + (q ** j) * up
        row = new
    return row
