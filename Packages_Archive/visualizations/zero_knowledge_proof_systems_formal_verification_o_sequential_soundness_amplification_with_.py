from itertools import permutations
from math import log, ceil
from typing import Dict, List, Tuple

Edge = Tuple[int, int]
Colouring = Dict[int, int]
Perm = Tuple[int, int, int]


def sequential_amplification(edges: List[Edge], committed: Colouring,
                             eps: float) -> Tuple[int, float]:
    """Return (rounds, cheating_prob) achieving soundness error < eps.

    The one-round acceptance probability of a prover committed to `committed`
    is the fraction of edges with distinct endpoints. Independent repetition
    multiplies it, so k rounds accept a cheat with probability p**k. We return
    the least k with p**k < eps.
    """
    m: int = len(edges)
    if m == 0:
        return 0, 0.0
    distinct: int = sum(1 for (u, v) in edges if committed[u] != committed[v])
    p: float = distinct / m
    if p <= 0.0:
        return 1, 0.0
    if p >= 1.0:
        raise ValueError("committed colouring is proper: no soundness error to amplify")
    k: int = max(1, ceil(log(eps) / log(p)))
    return k, p ** k
