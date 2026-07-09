from itertools import combinations
from typing import Dict, FrozenSet, Iterable

Edge = FrozenSet[int]
Coloring = Dict[Edge, bool]


def circulant(n: int, diffs: Iterable[int]) -> Coloring:
    """Red/blue colouring of K_n from a circulant difference set on Z/n."""
    dset = set()
    for d in diffs:
        dset.add(d % n); dset.add((-d) % n)
    return {frozenset((a, b)): ((a - b) % n in dset) for a, b in combinations(range(n), 2)}


def has_mono_clique(col: Coloring, n: int, size: int, red: bool) -> bool:
    """True iff some `size`-subset of [n] is monochromatic of the given colour."""
    return any(all(col[frozenset((a, b))] == red for a, b in combinations(S, 2))
               for S in combinations(range(n), size))


def certifies_lower_bound(col: Coloring, n: int, s: int, t: int) -> bool:
    """True iff the colouring avoids both a red s-clique and a blue t-clique,
    certifying R(s,t) > n."""
    return (not has_mono_clique(col, n, s, True)) and (not has_mono_clique(col, n, t, False))
