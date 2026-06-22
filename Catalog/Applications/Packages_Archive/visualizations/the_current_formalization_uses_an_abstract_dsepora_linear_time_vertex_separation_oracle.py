from __future__ import annotations
from typing import Dict, FrozenSet, List, Set


def separation_oracle(adj: Dict[int, Set[int]],
                      A: FrozenSet[int], B: FrozenSet[int],
                      Z: FrozenSet[int]) -> bool:
    """Decide A ⊥ B | Z by BFS from A in the Z-deleted graph.

    Returns True iff no vertex of B is reachable from A while avoiding Z.
    Complexity O(V + E) on the deleted graph.
    """
    if A & B:
        # a shared vertex is trivially "reachable" from itself
        return not bool((A & B) - Z)
    start: List[int] = [a for a in A if a not in Z]
    seen: Set[int] = set(start)
    frontier: List[int] = list(start)
    targets = set(B)
    while frontier:
        x = frontier.pop()
        for y in adj.get(x, ()):  # neighbours of x
            if y in Z or y in seen:
                continue
            if y in targets:
                return False
            seen.add(y)
            frontier.append(y)
    return True
