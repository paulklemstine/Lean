from __future__ import annotations
from typing import Callable, FrozenSet, Iterable, Set

def diagonal_witness(universe: Iterable[int],
                     index: Callable[[int], FrozenSet[int]]) -> FrozenSet[int]:
    """Construct the configuration D = { x : x not in index(x) }.

    By Cantor's argument D is never in the range of `index`, so it certifies
    non-surjectivity. Runs in O(|T|) evaluations of `index`.
    """
    U: Set[int] = set(universe)
    return frozenset(x for x in U if x not in index(x))

def is_unnamed(universe: Iterable[int],
               index: Callable[[int], FrozenSet[int]],
               d: FrozenSet[int]) -> bool:
    """Verify that no microstate x has index(x) == d."""
    return all(index(x) != d for x in universe)
