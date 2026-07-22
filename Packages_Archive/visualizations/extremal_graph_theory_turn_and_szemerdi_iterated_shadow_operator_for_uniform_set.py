from typing import FrozenSet, Iterable, Set

def shadow(family: Iterable[FrozenSet[int]]) -> Set[FrozenSet[int]]:
    out: Set[FrozenSet[int]] = set()
    for s in family:
        for x in s:
            out.add(s - {x})
    return out

def iterated_shadow(family: Iterable[FrozenSet[int]],
                    i: int) -> Set[FrozenSet[int]]:
    cur: Set[FrozenSet[int]] = set(map(frozenset, family))
    for _ in range(i):
        cur = shadow(cur)
    return cur
