from __future__ import annotations
import itertools
from typing import FrozenSet, List, Set

Face = FrozenSet[int]
Collection = Set[Face]


def echi(collection: Collection) -> int:
    """Signed Euler characteristic: sum of (-1)^|sigma| over faces sigma."""
    return sum((-1) ** len(sigma) for sigma in collection)


def echi_union_k(pieces: List[Collection]) -> int:
    """echi of the union via full k-set inclusion-exclusion over the nerve."""
    n = len(pieces)
    total = 0
    for r in range(1, n + 1):
        for combo in itertools.combinations(range(n), r):
            inter: Collection = set(pieces[combo[0]])
            for idx in combo[1:]:
                inter &= pieces[idx]
            total += ((-1) ** (r - 1)) * echi(inter)
    return total
