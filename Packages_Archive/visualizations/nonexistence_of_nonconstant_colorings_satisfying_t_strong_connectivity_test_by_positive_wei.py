from __future__ import annotations
from typing import List, Set

def reachable_set(W: List[List[float]], src: int, tol: float = 1e-12) -> Set[int]:
    n = len(W)
    seen: Set[int] = {src}
    stack = [src]
    while stack:
        i = stack.pop()
        for j in range(n):
            if W[i][j] > tol and j not in seen:
                seen.add(j)
                stack.append(j)
    return seen

def is_strongly_connected(W: List[List[float]]) -> bool:
    """True iff every vertex reaches every other along positive-weight arcs."""
    n = len(W)
    return all(len(reachable_set(W, i)) == n for i in range(n))
