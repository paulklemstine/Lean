from itertools import combinations
from typing import FrozenSet, List, TypeVar

T = TypeVar("T")
Family = List[FrozenSet[T]]


def union_closure(F: Family) -> Family:
    """Compute the union closure <F>: the least union-closed family containing F.

    The supremum-of-subfamilies definition is equivalent to the fixed point of
    pairwise union (the ground set is finite, so the iteration terminates).
    """
    closure: set = set(F)
    changed = True
    while changed:
        changed = False
        for s, t in combinations(list(closure), 2):
            u = s | t
            if u not in closure:
                closure.add(u)
                changed = True
    return list(closure)
