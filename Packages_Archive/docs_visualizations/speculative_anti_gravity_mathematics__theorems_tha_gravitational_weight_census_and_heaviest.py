from typing import Callable, Dict, List

def all_weights(V: List[object], D: Callable[[object, object], bool]) -> Dict[object, int]:
    """
    Compute the gravitational weight w(a) = #{ b : D(a, b) } for every theorem a.
    Direct double loop over the vertex set; O(N^2) relation queries.
    """
    weights: Dict[object, int] = {}
    for a in V:
        weights[a] = sum(1 for b in V if D(a, b))
    return weights

def heaviest(V: List[object], D: Callable[[object, object], bool]) -> object:
    """Return a theorem of maximum gravitational weight (a most-foundational result)."""
    w = all_weights(V, D)
    return max(V, key=lambda a: w[a])
