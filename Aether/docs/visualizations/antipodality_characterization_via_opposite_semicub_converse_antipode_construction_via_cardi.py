from __future__ import annotations
from itertools import product
from typing import FrozenSet, List, Optional, Tuple

Vertex = Tuple[int, ...]

def semicube(S: FrozenSet[Vertex], i: int, b: int) -> FrozenSet[Vertex]:
    return frozenset(v for v in S if v[i] == b)

def cardinality_balanced(S: FrozenSet[Vertex], n: int) -> bool:
    return all(len(semicube(S, i, 0)) == len(semicube(S, i, 1)) for i in range(n))

def construct_antipode(S: FrozenSet[Vertex], v: Vertex, n: int) -> Optional[Vertex]:
    """
    Converse construction: assuming cardinality balance (from isometry) and the
    Helly property, the flip constraints {(i, 1 - v[i])} have a unique common
    witness in S, namely the antipode of v.
    """
    F = [(i, 1 - v[i]) for i in range(n)]
    for x in S:
        if all(x[i] == b for (i, b) in F):
            return x
    return None
