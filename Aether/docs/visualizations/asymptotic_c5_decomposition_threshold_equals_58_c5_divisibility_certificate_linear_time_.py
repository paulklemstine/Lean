from __future__ import annotations
from fractions import Fraction
from typing import Dict, FrozenSet, Set

Edge = FrozenSet[int]
Graph = Set[Edge]


def degree(g: Graph, w: int) -> int:
    """Number of edges incident to w."""
    return sum(1 for e in g if w in e)


def vertices(g: Graph) -> Set[int]:
    out: Set[int] = set()
    for e in g:
        out |= set(e)
    return out


def is_c5_divisible(g: Graph) -> bool:
    """
    Decide the necessary divisibility conditions for a C5-decomposition:
      (1) 5 | |E(G)|                 (global divisibility)
      (2) every vertex has even degree (local parity)
    Returns True iff both hold.  By no_decomposition_of_not_divisible, a
    False result is a *certificate of non-decomposability*.
    Runs in O(|V| + |E|).
    """
    if len(g) % 5 != 0:
        return False
    deg: Dict[int, int] = {}
    for e in g:
        for x in e:
            deg[x] = deg.get(x, 0) + 1
    return all(d % 2 == 0 for d in deg.values())
