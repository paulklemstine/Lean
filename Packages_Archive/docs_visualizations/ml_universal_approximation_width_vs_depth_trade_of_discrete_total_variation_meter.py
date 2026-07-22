from __future__ import annotations
from typing import Callable


def discrete_tv(g: Callable[[float], float], k: int) -> float:
    """Discrete total variation of g over the 2^k-cell dyadic grid of [0, 1].

    Sums absolute consecutive differences across 2^k cells; O(2^k) evals.
    Certifies TV_k(tent^[k]) = 2^k and TV_k(shallow) <= sum_j |a_j|.
    """
    n = 2 ** k
    nodes = [i / n for i in range(n + 1)]
    return sum(abs(g(nodes[i + 1]) - g(nodes[i])) for i in range(n))
