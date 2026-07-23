from __future__ import annotations
from typing import FrozenSet, Hashable, Iterable, TypeVar
Leaf = TypeVar("Leaf", bound=Hashable)
SplitSystem = FrozenSet[FrozenSet[Leaf]]
def restrict_system(system: SplitSystem[Leaf], retained: Iterable[Leaf]) -> SplitSystem[Leaf]:
    keep = frozenset(retained)
    return frozenset(side & keep for side in system)
if __name__ == "__main__":
    t = frozenset(map(frozenset, [{1,2,3},{2,4},{1,4,5}]))
    a, b = frozenset({1,2,4}), frozenset({2,4,5})
    assert restrict_system(restrict_system(t,a),b) == restrict_system(t,a & b)
    print("Restriction composition confirmed.")
