from __future__ import annotations
from typing import Callable, Hashable, Sequence

def is_free_action(group: Sequence[Hashable],
                   points: Sequence[Hashable],
                   act: Callable[[Hashable, Hashable], Hashable],
                   identity: Hashable) -> bool:
    """Decide whether a finite group action is free.

    Returns True iff the only element fixing any point is the identity.
    Complexity: O(|group| * |points|) action evaluations.
    """
    for x in points:
        for g in group:
            if g != identity and act(g, x) == x:
                return False
    return True
