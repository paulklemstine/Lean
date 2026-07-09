from __future__ import annotations
import itertools
from fractions import Fraction
from typing import Dict, Sequence, Set

Graph = Dict[int, Set[int]]


def exact_independence_ratio(graph: Graph) -> Fraction:
    """Compute the exact independence ratio alpha(G)/n by enumerating subsets
    from largest to smallest and returning the first independent one found.
    Exponential in |V|; intended for small certifying instances such as K_3.
    """
    def independent(sub: Sequence[int]) -> bool:
        s = set(sub)
        return all(not (graph[u] & s - {u}) for u in s)

    V = list(graph)
    n = len(V)
    if n == 0:
        return Fraction(0)
    for r in range(n, -1, -1):
        for sub in itertools.combinations(V, r):
            if independent(sub):
                return Fraction(r, n)
    return Fraction(0)
