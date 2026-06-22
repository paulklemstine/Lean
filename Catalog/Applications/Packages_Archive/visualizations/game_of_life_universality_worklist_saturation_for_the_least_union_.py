from __future__ import annotations

from itertools import combinations
from typing import Hashable, FrozenSet, List, Set

Subset = FrozenSet[Hashable]
Family = List[Subset]


def union_closure(F: Family) -> Family:
    """Compute the least union-closed family containing F by worklist
    saturation.

    Mathematical foundation: by Lemma 5 (extensiveness) the result contains F,
    and by Lemma 6 it is union-closed; since every produced set is a union of
    members of F it is the *least* such family. Termination is guaranteed
    because every member is a subset of the (finite) ground set, so the member
    pool is bounded by 2^|alpha|.

    Complexity: each saturation pass costs O(m^2) union operations where m is
    the current member count; the number of passes is bounded by the final
    size, giving a worst case of O(M^3) set-unions with M = |closure(F)| up to
    2^|alpha|.
    """
    members: Set[Subset] = set(F)
    changed = True
    while changed:
        changed = False
        snapshot = list(members)
        for s in snapshot:
            for t in snapshot:
                u = s | t
                if u not in members:
                    members.add(u)
                    changed = True
    return list(members)
