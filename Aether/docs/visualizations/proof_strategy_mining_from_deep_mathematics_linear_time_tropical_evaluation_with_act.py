from __future__ import annotations
from typing import List, Tuple

def trop_poly_eval(c: List[float], x: float) -> Tuple[float, int]:
    """Evaluate tropPoly_c(x) = max_i (c[i] + i*x) and return an attaining index.

    Correctness: the returned index witnesses the attainment theorem,
    tropPoly_c(x) == c[best_i] + best_i * x. Complexity: O(d).
    """
    best_i: int = 0
    best_v: float = c[0] + 0 * x
    for i in range(1, len(c)):
        v: float = c[i] + i * x
        if v > best_v:
            best_i, best_v = i, v
    return best_v, best_i
