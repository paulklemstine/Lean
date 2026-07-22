from __future__ import annotations
from typing import FrozenSet, Tuple
Edge = FrozenSet[str]
def maximum_pair_star_matching(s: int, t: int) -> Tuple[Edge, ...]:
    if s < 0 or t < 0:
        raise ValueError("parameters must be nonnegative")
    return tuple(frozenset((f"p{i}_0", f"p{i}_1", f"x{i}")) for i in range(min(s, t)))
def is_matching(edges: Tuple[Edge, ...]) -> bool:
    return all(edges[i].isdisjoint(edges[j]) for i in range(len(edges)) for j in range(i))
if __name__ == "__main__":
    witness = maximum_pair_star_matching(5, 7)
    print(len(witness), is_matching(witness))
