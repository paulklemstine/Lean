from itertools import chain, combinations
from typing import Callable, Dict, FrozenSet, Iterable, List

Simplex = FrozenSet[int]
Filtration = Dict[Simplex, float]


def all_nonempty_simplices(labels: Iterable[int]) -> List[Simplex]:
    items = list(labels)
    subs = chain.from_iterable(combinations(items, r) for r in range(1, len(items) + 1))
    return [frozenset(s) for s in subs]


def make_monotone_filtration(labels: Iterable[int], vertex_time: Dict[int, float]) -> Filtration:
    return {s: max(vertex_time[v] for v in s) for s in all_nonempty_simplices(labels)}


def shift(a: float, F: Filtration) -> Filtration:
    if a < 0:
        raise ValueError("shift amount must be non-negative")
    return {s: w - a for s, w in F.items()}


def comap(e: Callable[[int], int], F: Filtration) -> Filtration:
    return {s: F[frozenset(e(v) for v in s)] for s in F}


def interleaving_distance(F: Filtration, G: Filtration) -> float:
    return max(abs(F[s] - G[s]) for s in F)


def relabeling_invariant(F: Filtration, G: Filtration,
                         e: Callable[[int], int], tol: float = 1e-12) -> bool:
    """Executable witness of interleavingDist_comap: distance is unchanged by comap e."""
    d0 = interleaving_distance(F, G)
    d1 = interleaving_distance(comap(e, F), comap(e, G))
    return abs(d0 - d1) <= tol
