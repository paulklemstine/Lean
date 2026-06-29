from collections import deque
from typing import Dict, FrozenSet, List, Optional, Tuple

Theory = FrozenSet[Tuple[int, int]]

def min_proof_length(theory: Theory, a: int, b: int) -> Optional[int]:
    """Shortest derivation length a -> ... -> b via BFS; None if non-derivable.

    Realizes the diameter-length identity (length n in the chain theory)."""
    adj: Dict[int, List[int]] = {}
    for x, y in theory:
        adj.setdefault(x, []).append(y)
    dist: Dict[int, int] = {a: 0}
    queue: deque[int] = deque([a])
    while queue:
        x = queue.popleft()
        if x == b:
            return dist[x]
        for y in adj.get(x, ()):
            if y not in dist:
                dist[y] = dist[x] + 1
                queue.append(y)
    return dist.get(b)
