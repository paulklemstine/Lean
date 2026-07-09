from __future__ import annotations
from collections import deque
from typing import FrozenSet

def incoherence_index(n: int, frame: FrozenSet[int]) -> int:
    """Length of the shortest non-empty zero-sum word over `frame` in Z/nZ.

    Returns 0 for a coherent frame (no such word exists).
    Runs in O(n * |frame|) time via breadth-first search on residues.
    """
    if not frame:
        return 0
    INF = float('inf')
    dist = [INF] * n
    queue: deque[int] = deque()
    for a in frame:
        r = a % n
        if dist[r] > 1:
            dist[r] = 1
            queue.append(r)
    while queue:
        r = queue.popleft()
        if r == 0:
            return dist[0]
        for a in frame:
            r2 = (r + a) % n
            if dist[r2] > dist[r] + 1:
                dist[r2] = dist[r] + 1
                queue.append(r2)
    return 0 if dist[0] == INF else int(dist[0])
