from __future__ import annotations
from typing import List, Sequence

def argmin_index(h: Sequence[float], m: Sequence[float]) -> int:
    best_i, best_v = 0, m[0] + h[0]
    for i in range(1, len(m)):
        v = m[i] + h[i]
        if v < best_v:
            best_i, best_v = i, v
    return best_i

def collide(h: Sequence[float], m: Sequence[float],
            delta: float = 1.0) -> List[float]:
    """Return m' != m with the same tropical digest; requires k >= 2, delta > 0."""
    if len(m) < 2:
        raise ValueError("collisions are guaranteed only for k >= 2")
    i_star = argmin_index(h, m)
    k_star = 1 if i_star == 0 else 0
    mp = list(m)
    mp[k_star] += delta
    return mp
