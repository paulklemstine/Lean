from __future__ import annotations
from typing import Callable, FrozenSet, Hashable, List, Set

World = Hashable

def box(worlds: List[World], R: Callable[[World, World], bool],
        S: Set[World]) -> Set[World]:
    """box S = { w | every R-successor of w lies in S }."""
    return {w for w in worlds
            if all(v in S for v in worlds if R(w, v))}

def box_iterate_stratify(worlds: List[World],
                         R: Callable[[World, World], bool],
                         kmax: int) -> List[FrozenSet[World]]:
    """Compute the increasing chain S_k = box^k(empty) for k = 0..kmax.

    By the rank-stratification theorem, S_k = { w | rank w < k }, so the index
    at which a world first enters the chain equals its ordinal rank.
    Each iteration is O(|R|); the chain stabilizes once k exceeds the max rank.
    """
    chain: List[FrozenSet[World]] = []
    cur: Set[World] = set()
    for _ in range(kmax + 1):
        chain.append(frozenset(cur))
        cur = box(worlds, R, cur)
    return chain
