from __future__ import annotations
from itertools import combinations
from typing import FrozenSet, Iterable, Set, Tuple
Face = FrozenSet[int]
Attack = Tuple[int, int]
def subsets(n: int) -> Iterable[Face]:
    for k in range(n + 1):
        for s in combinations(range(n), k):
            yield frozenset(s)
def conflict_free(s: Face, attacks: Set[Attack]) -> bool:
    return all((a, b) not in attacks for a in s for b in s)
def defends(s: Face, a: int, n: int, attacks: Set[Attack]) -> bool:
    return all(any((c, b) in attacks for c in s) for b in range(n) if (b, a) in attacks)
def admissible(s: Face, n: int, attacks: Set[Attack]) -> bool:
    return conflict_free(s, attacks) and all(defends(s, a, n, attacks) for a in s)
def preferred(n: int, attacks: Set[Attack]) -> list[Face]:
    good=[s for s in subsets(n) if admissible(s,n,attacks)]
    return [s for s in good if not any(s<t for t in good)]
def closure(facets: list[Face]) -> set[Face]:
    return {frozenset(s) for f in facets for k in range(len(f)+1) for s in combinations(f,k)}

def enumerate_preferred(n: int, attacks: Set[Attack]) -> list[Face]:
    candidates=[s for s in subsets(n) if admissible(s,n,attacks)]
    return [s for s in candidates if not any(s<t for t in candidates)]
