from __future__ import annotations
from typing import Callable, Dict, List, Sequence


def reconstruct_on_wedge(
    bulk: Sequence[int], boundary: Sequence[int], B: Sequence[int],
    d: Callable[[int, int], float],
    obs_target: Dict[int, float],
    phi_candidate: Callable[[int], float],
) -> Dict[int, bool]:
    """Decide, per wedge vertex, whether a candidate bulk state matches boundary data.

    1. Compute Wedge(B) by strict min-plus distance comparison.
    2. For each b in B compute Obs(phi)(b) = min_v (phi(v) + d(v,b)).
    3. A vertex is consistent if observations match the target on all of B.
    Complexity O(|bulk| * |boundary|).
    """
    Bset = set(B)
    Bc = [b for b in boundary if b not in Bset]

    def dist(S: Sequence[int], v: int) -> float:
        return min(d(v, b) for b in S)

    wedge = [v for v in bulk
             if (not Bset) or (not Bc) or dist(list(Bset), v) < dist(Bc, v)]

    def obs(b: int) -> float:
        return min(phi_candidate(v) + d(v, b) for v in bulk)

    matches = all(abs(obs(b) - obs_target[b]) < 1e-12 for b in B)
    return {v: matches for v in wedge}
