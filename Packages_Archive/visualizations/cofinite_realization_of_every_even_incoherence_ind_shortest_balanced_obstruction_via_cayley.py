from collections import deque
from math import gcd
from typing import Iterable

def incoherence_index(frame: Iterable[int], N: int) -> int:
    """Shortest nonempty zero-sum sequence over `frame` in Z_N, computed as the
    girth of the Cayley graph Cay(Z_N, frame). Returns 0 if none exists."""
    atoms = sorted({a % N for a in frame})
    if not atoms:
        return 0
    dist = [-1] * N
    dist[0] = 0
    queue = deque([0])
    while queue:
        r = queue.popleft()
        for a in atoms:
            s = (r + a) % N
            if s == 0:
                return dist[r] + 1
            if dist[s] == -1:
                dist[s] = dist[r] + 1
                queue.append(s)
    return 0
