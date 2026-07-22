from __future__ import annotations
from typing import FrozenSet, List, Set, Tuple

Statement = FrozenSet[int]
System = Set[Statement]

def tail_system(n: int, top: int) -> System:
    return {frozenset({m}) for m in range(n, top)}

def descending_chain(top: int) -> Tuple[List[System], bool]:
    chain = [tail_system(n, top) for n in range(top)]
    strict = all(chain[n + 1].issubset(chain[n]) and chain[n + 1] != chain[n]
                 for n in range(top - 1))
    return chain, strict
