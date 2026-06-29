from itertools import chain, combinations
from typing import FrozenSet, List, Set, Tuple

Point = int


def _powerset(carrier: FrozenSet[Point]) -> List[FrozenSet[Point]]:
    xs = list(carrier)
    return [frozenset(c) for c in chain.from_iterable(
        combinations(xs, r) for r in range(len(xs) + 1))]


def lower_set_topology(
    carrier: FrozenSet[Point], leq: Set[Tuple[Point, Point]]
) -> FrozenSet[FrozenSet[Point]]:
    """Open sets = lower sets of the preorder `leq` (pairs (y, x) with y <= x)."""
    def is_lower(s: FrozenSet[Point]) -> bool:
        return all((y in s) for (y, x) in leq if x in s)
    return frozenset(s for s in _powerset(carrier) if is_lower(s))
