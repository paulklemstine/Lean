from __future__ import annotations
from itertools import combinations
from typing import List, Tuple

Semicube = Tuple[int, bool]


def find_obstruction(family: List[Semicube]
                     ) -> Tuple[bool, Tuple[Semicube, Semicube] | None]:
    """Certify pairwise intersection of a semicube family, or exhibit the
    unique kind of obstruction: two semicubes (i, b) and (i, not b) sharing a
    coordinate with opposite bits. Time O(|family|) using a single pass."""
    seen: dict[int, bool] = {}
    for i, b in family:
        if i in seen and seen[i] != b:
            return False, ((i, seen[i]), (i, b))
        seen[i] = b
    return True, None
