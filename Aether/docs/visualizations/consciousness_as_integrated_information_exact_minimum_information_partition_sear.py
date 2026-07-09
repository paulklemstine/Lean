from itertools import chain, combinations
from typing import Callable, FrozenSet, List, Tuple

Cut = FrozenSet[int]
EI = Callable[[Cut], float]


def nontrivial_cuts(n: int) -> List[Cut]:
    """All nonempty proper subsets of {0,...,n-1} (the cut landscape)."""
    elts = tuple(range(n))
    full = frozenset(elts)
    subsets = chain.from_iterable(combinations(elts, r) for r in range(n + 1))
    return [frozenset(s) for s in subsets if 0 < len(s) and frozenset(s) != full]


def phi_and_mip(n: int, ei: EI) -> Tuple[float, Cut]:
    """Exact integrated information Phi and a Minimum Information Partition.

    Requires n >= 2 (otherwise the cut landscape is empty and Phi is undefined).
    Returns (Phi, A_star) where Phi = min_A ei(A) and ei(A_star) = Phi.
    Cost: Theta(2^n) evaluations of ei.
    """
    cuts = nontrivial_cuts(n)
    if not cuts:
        raise ValueError("Phi undefined: n must be >= 2.")
    a_star = min(cuts, key=ei)        # argmin exists (finite, nonempty)
    return ei(a_star), a_star
