from itertools import chain, combinations
from typing import Callable, FrozenSet, List, Sequence

Subset = FrozenSet[int]
SetFunction = Callable[[Subset], float]


def powerset(ground: Sequence[int]) -> List[Subset]:
    return [frozenset(c) for c in chain.from_iterable(
        combinations(ground, r) for r in range(len(ground) + 1))]


def slice_proj(f: SetFunction, s: Subset) -> SetFunction:
    """Contraction by slice s: A -> f(A | s) - f(s)."""
    base: float = f(s)
    return lambda a: f(a | s) - base


def connectivity(f: SetFunction, ground: Sequence[int], a: Subset) -> float:
    """lambda(A) = f(A) + f(A^c) - f(E)."""
    full: Subset = frozenset(ground)
    return f(a) + f(full - a) - f(full)


def connectivity_profile(base: SetFunction, ground: Sequence[int],
                         slices: Sequence[Subset]) -> List[bool]:
    """Boolean connectivity verdict per slice level (Algorithm B)."""
    profile: List[bool] = []
    for s in slices:
        g = slice_proj(base, s)
        cuts = [connectivity(g, ground, a) for a in powerset(ground)
                if 0 < len(a) < len(ground)]
        kappa = min(cuts) if cuts else 0.0
        profile.append(kappa > 1e-9)
    return profile
