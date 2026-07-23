from __future__ import annotations
from typing import FrozenSet, Hashable, Iterable, Sequence, TypeVar
Leaf = TypeVar("Leaf", bound=Hashable)
SplitSystem = FrozenSet[FrozenSet[Leaf]]
def restrict_system(t: SplitSystem[Leaf], a: Iterable[Leaf]) -> SplitSystem[Leaf]:
    keep=frozenset(a); return frozenset(s & keep for s in t)
def common_state(trees: Sequence[SplitSystem[Leaf]], a: Iterable[Leaf]) -> SplitSystem[Leaf] | None:
    if not trees: return frozenset()
    base=restrict_system(trees[0],a)
    return base if all(restrict_system(t,a)==base for t in trees[1:]) else None
if __name__ == "__main__":
    shared=[{1,2},{3,4},{1,5}]
    trees=[frozenset(frozenset(s|{x}) for s in shared) for x in (10,20,30,40)]
    print(common_state(trees,{1,2,3,4,5}))
