from __future__ import annotations
from typing import FrozenSet, Iterator, List, Set, Tuple

Edge = FrozenSet[int]
Graph = Tuple[Set[int], Set[Edge]]


def count_perfect_matchings(g: Graph, cap: int = 2) -> int:
    """Count perfect matchings, stopping once `cap` are found."""
    V, E = g
    found = 0

    def bt(rem: Tuple[int, ...]) -> Iterator[None]:
        nonlocal found
        if found >= cap:
            return
        if not rem:
            found += 1
            yield None
            return
        a, rest = rem[0], rem[1:]
        for b in rest:
            if frozenset((a, b)) in E:
                for _ in bt(tuple(x for x in rest if x != b)):
                    yield None
                    if found >= cap:
                        return

    for _ in bt(tuple(sorted(V))):
        if found >= cap:
            break
    return found


def is_forcing_edge(g: Graph, u: int, v: int) -> bool:
    """Deletion test: uv is forcing iff G - u - v has exactly one perfect matching."""
    V, E = g
    if frozenset((u, v)) not in E:
        return False
    sub: Graph = ({w for w in V if w not in (u, v)},
                  {e for e in E if u not in e and v not in e})
    return count_perfect_matchings(sub, cap=2) == 1
