from itertools import chain, combinations
from typing import Callable, Dict, FrozenSet, Iterable, List

Simplex = FrozenSet[int]
Filtration = Dict[Simplex, float]


def powerset(vertices: Iterable[int]) -> List[Simplex]:
    items = list(vertices)
    return [frozenset(c) for c in chain.from_iterable(
        combinations(items, r) for r in range(len(items) + 1))]


def pullback(f: Callable[[int], int], F: Filtration,
             vertices_alpha: Iterable[int]) -> Filtration:
    """(pullback f F)(sigma) = F(image of sigma under f)."""
    out: Filtration = {}
    for sigma in powerset(vertices_alpha):
        out[sigma] = F[frozenset(f(v) for v in sigma)]
    return out
