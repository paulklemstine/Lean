from __future__ import annotations
from typing import Callable, Dict, List, Set, Tuple

def stratify(worlds: List[int], succ: Dict[int, Set[int]], k: int
             ) -> Tuple[Set[int], Set[int]]:
    """Return (box^k(empty), diamond^k(univ)) for a finite GL frame.

    By the stratification theorems these equal {rank<k} and {rank>=k}, and are
    exact set complements.  Each operator pass is O(|worlds|+|edges|); total
    O(k * (|worlds|+|edges|)).
    """
    box: Callable[[Set[int]], Set[int]] = lambda S: {w for w in worlds if succ[w] <= S}
    dia: Callable[[Set[int]], Set[int]] = lambda S: {w for w in worlds if succ[w] & S}
    b: Set[int] = set()
    d: Set[int] = set(worlds)
    for _ in range(k):
        b, d = box(b), dia(d)
    return b, d
