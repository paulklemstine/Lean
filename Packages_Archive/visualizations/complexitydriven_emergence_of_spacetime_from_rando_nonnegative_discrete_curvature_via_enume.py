from itertools import combinations
from typing import Callable, FrozenSet, List, Sequence, Tuple

Region = FrozenSet[int]


def syndrome_defect(S: Callable[[Region], float], X: Region, Y: Region) -> float:
    """defect(X,Y) = S(X) + S(Y) - S(X & Y) - S(X | Y)."""
    return S(X) + S(Y) - S(X & Y) - S(X | Y)


def verify_nonneg_curvature(sites: Sequence[int],
                            S: Callable[[Region], float]) -> Tuple[float, bool]:
    """Enumerate all region pairs, compute the syndrome defect (discrete curvature),
    and certify nonnegativity (the finite content of syndromeDefect_nonneg)."""
    regions: List[Region] = []
    for k in range(len(sites) + 1):
        for combo in combinations(sites, k):
            regions.append(frozenset(combo))
    worst = float("inf")
    ok = True
    for X in regions:
        for Y in regions:
            d = syndrome_defect(S, X, Y)
            worst = min(worst, d)
            if d < -1e-12:
                ok = False
    return worst, ok
