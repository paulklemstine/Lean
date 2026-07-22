from __future__ import annotations
from itertools import permutations
from typing import FrozenSet, List, Optional, Tuple

Vertex = Tuple[int, ...]

def hamming(u: Vertex, v: Vertex) -> int:
    return sum(1 for a, b in zip(u, v) if a != b)

def semicube(S: FrozenSet[Vertex], i: int, b: int) -> FrozenSet[Vertex]:
    return frozenset(v for v in S if v[i] == b)

def is_isometric_iso(A: FrozenSet[Vertex], B: FrozenSet[Vertex]) -> bool:
    """Decide whether finite sets A, B are isometrically isomorphic (Hamming)."""
    if len(A) != len(B):
        return False
    la, lb = list(A), list(B)
    for perm in permutations(lb):
        if all(hamming(la[i], la[j]) == hamming(perm[i], perm[j])
               for i in range(len(la)) for j in range(i + 1, len(la))):
            return True
    return False

def antipodality_by_semicubes(S: FrozenSet[Vertex], n: int) -> bool:
    """Report antipodal iff every pair of opposite semicubes is isometric."""
    for i in range(n):
        if not is_isometric_iso(semicube(S, i, 0), semicube(S, i, 1)):
            return False
    return True
