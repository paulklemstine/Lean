from __future__ import annotations
from typing import List

def leading_term_threshold(c: List[float]) -> float:
    """Return the smallest T with tropPoly_c(x) = c[d] + d*x for all x >= T.

    The leading line c[d]+d*x overtakes line i (i<d) at the crossing point
    T_i = (c[i]-c[d])/(d-i); the global threshold is the maximum of all T_i.
    Returns -inf for the degenerate degree-0 case. Complexity: O(d).
    """
    d: int = len(c) - 1
    if d == 0:
        return float("-inf")
    crossings: List[float] = [(c[i] - c[d]) / (d - i) for i in range(d)]
    return max(crossings)
