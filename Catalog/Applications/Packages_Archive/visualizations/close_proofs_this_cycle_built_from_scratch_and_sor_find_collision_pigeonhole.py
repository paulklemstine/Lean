from typing import Callable, Dict, Hashable, Optional, Tuple

def find_collision(encoder: Callable[[int], Hashable], n: int, k: int
                   ) -> Optional[Tuple[int, int]]:
    """Return a pair (i, j) with i < j <= k and E(i) == E(j), or None.

    By the Collision Theorem, if |codomain| < k + 1 and k < n then a collision
    among indices <= k is guaranteed to exist.
    """
    seen: Dict[Hashable, int] = {}
    for i in range(n):
        if i > k:
            break
        v = encoder(i)
        if v in seen:
            return (seen[v], i)
        seen[v] = i
    return None
