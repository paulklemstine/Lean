from __future__ import annotations

from itertools import combinations
from typing import Callable, Dict, FrozenSet, List, Sequence, Tuple

Point = int
Simplex = FrozenSet[Point]
DistMatrix = Dict[Tuple[Point, Point], float]


def diam_weight_of(d: DistMatrix, sigma: Simplex) -> float:
    """Diameter weight of a simplex: max pairwise distance, 0 if < 2 vertices."""
    pairs = list(combinations(sorted(sigma), 2))
    return max((d[(x, y)] for (x, y) in pairs), default=0.0)


def all_simplices(vertices: Sequence[Point]) -> List[Simplex]:
    """All faces (including the empty simplex) of the full simplex."""
    faces: List[Simplex] = [frozenset()]
    for k in range(1, len(vertices) + 1):
        faces.extend(frozenset(c) for c in combinations(vertices, k))
    return faces


def sublevel_faces(weight: Callable[[Simplex], float],
                   simplices: Sequence[Simplex], t: float) -> FrozenSet[Simplex]:
    """{ sigma : weight sigma <= t }."""
    return frozenset(s for s in simplices if weight(s) <= t + 1e-12)


def is_delta_interleaved(w1: Callable[[Simplex], float],
                         w2: Callable[[Simplex], float],
                         simplices: Sequence[Simplex],
                         delta: float,
                         critical_scales: Sequence[float]) -> bool:
    """Exact check of Interleaved(F,G,delta) for monotone weights on a finite
    simplex set: it suffices to test the finitely many critical (birth) scales,
    since both sublevel families are step functions of t with jumps only there.
    """
    if delta < 0:
        return False
    for t in critical_scales:
        if not (sublevel_faces(w1, simplices, t) <= sublevel_faces(w2, simplices, t + delta)):
            return False
        if not (sublevel_faces(w2, simplices, t) <= sublevel_faces(w1, simplices, t + delta)):
            return False
    return True


def interleaving_distance(d1: DistMatrix, d2: DistMatrix,
                          vertices: Sequence[Point],
                          tol: float = 1e-6) -> float:
    """Compute the interleaving distance between the two Vietoris-Rips
    filtrations of d1 and d2 by bisection on the shift delta.

    Monotonicity (Interleaved_mono): if a delta works, every delta' >= delta
    works, so the set of admissible shifts is an up-set [d*, infinity) and the
    interleaving distance d* is found by binary search.  Complexity:
    O(log(1/tol) * S^2) set comparisons where S = 2^|vertices| is the number of
    simplices.
    """
    simplices = all_simplices(vertices)
    w1: Callable[[Simplex], float] = lambda s: diam_weight_of(d1, s)
    w2: Callable[[Simplex], float] = lambda s: diam_weight_of(d2, s)
    crit = sorted({w1(s) for s in simplices} | {w2(s) for s in simplices})

    # Upper bound: sup-norm distance of the weights (Theorem 5.4 guarantees it
    # is an admissible shift).
    hi = max(abs(w1(s) - w2(s)) for s in simplices)
    if not is_delta_interleaved(w1, w2, simplices, hi, crit):
        # Fallback: never happens under the stability theorem, but stay safe.
        return float("inf")
    lo = 0.0
    while hi - lo > tol:
        mid = 0.5 * (lo + hi)
        if is_delta_interleaved(w1, w2, simplices, mid, crit):
            hi = mid
        else:
            lo = mid
    return hi
