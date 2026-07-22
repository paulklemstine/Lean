from typing import Callable, List

def dep_weight(V: List[object], D: Callable[[object, object], bool], a: object) -> int:
    return sum(1 for b in V if D(a, b))

def find_anti_gravity(V: List[object], D: Callable[[object, object], bool],
                      plen: Callable[[object], int], w0: int, l0: int) -> List[object]:
    """
    Return every anti-gravity theorem at thresholds (w0, l0): those with
    gravitational weight >= w0 AND proof length <= l0.

    Strategy (mirrors the existence proof): restrict to the short-proof set S,
    then keep the ones whose weight clears w0. If the total weight of S is at
    least w0 * |S|, the result is guaranteed non-empty (pigeonhole).
    Complexity: O(N^2) weight computations plus O(N) filtering.
    """
    S: List[object] = [a for a in V if plen(a) <= l0]
    return [a for a in S if dep_weight(V, D, a) >= w0]

def guaranteed_threshold(V: List[object], D: Callable[[object, object], bool],
                         plen: Callable[[object], int], l0: int) -> int:
    """Largest w0 for which the pigeonhole bound still guarantees a witness in S."""
    S = [a for a in V if plen(a) <= l0]
    if not S:
        return 0
    return sum(dep_weight(V, D, a) for a in S) // len(S)
