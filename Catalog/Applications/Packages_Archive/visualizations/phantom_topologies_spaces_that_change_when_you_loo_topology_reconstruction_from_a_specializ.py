from itertools import chain, combinations
from typing import FrozenSet, List, Set, Tuple

Point = int


def _powerset(carrier: FrozenSet[Point]) -> List[FrozenSet[Point]]:
    xs = list(carrier)
    return [frozenset(c) for c in chain.from_iterable(
        combinations(xs, r) for r in range(len(xs) + 1))]


def is_down_closed(s: FrozenSet[Point], rel: Set[Tuple[Point, Point]]) -> bool:
    return all((b in s) for (b, a) in rel if a in s)


def reconstruct_topology(
    carrier: FrozenSet[Point], rel: Set[Tuple[Point, Point]]
) -> FrozenSet[FrozenSet[Point]]:
    """Open sets are exactly the down-closed subsets (Theorems 2 & 3)."""
    return frozenset(s for s in _powerset(carrier) if is_down_closed(s, rel))
