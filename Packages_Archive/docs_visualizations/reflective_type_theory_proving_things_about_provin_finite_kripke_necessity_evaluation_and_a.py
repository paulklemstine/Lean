from __future__ import annotations
from typing import FrozenSet, Tuple
Worlds = FrozenSet[int]
Edges = FrozenSet[Tuple[int, int]]
def box(worlds: Worlds, edges: Edges, p: Worlds) -> Worlds:
    return frozenset(w for w in worlds if all(v in p for u, v in edges if u == w))
def main() -> None:
    worlds, edges, p = frozenset({0,1,2}), frozenset({(2,1),(1,0)}), frozenset({1})
    once = box(worlds, edges, p); twice = box(worlds, edges, once)
    print("P =", sorted(p), "box P =", sorted(once), "box box P =", sorted(twice))
    print("World 2 witnesses the gap:", 2 in once and 2 not in twice)
if __name__ == "__main__": main()
