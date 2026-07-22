from __future__ import annotations
from typing import Optional


def extremal_coloring(n: int, targets: list[int]) -> Optional[tuple[int, ...]]:
    """Capacity-respecting coloring of K_n, or None if n exceeds capacity."""
    if n > sum(s - 1 for s in targets):
        return None
    coloring: list[int] = []
    for color, s in enumerate(targets):
        coloring.extend([color] * (s - 1))
        if len(coloring) >= n:
            break
    return tuple(coloring[:n])
