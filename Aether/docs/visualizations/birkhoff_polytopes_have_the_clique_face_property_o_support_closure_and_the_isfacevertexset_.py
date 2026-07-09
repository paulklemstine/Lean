from itertools import permutations
from typing import FrozenSet, List, Set, Tuple
Perm = Tuple[int, ...]
Cell = Tuple[int, int]

def support(p: Perm) -> FrozenSet[Cell]:
    return frozenset((i, p[i]) for i in range(len(p)))

def support_union(perms: List[Perm]) -> Set[Cell]:
    u: Set[Cell] = set()
    for p in perms:
        u |= support(p)
    return u

def face_closure(n: int, perms: List[Perm]) -> Set[Perm]:
    """All permutations of [n] supported within the support union of `perms`."""
    u = support_union(perms)
    return {tuple(p) for p in permutations(range(n)) if support(tuple(p)) <= u}

def is_face_vertex_set(n: int, perms: List[Perm]) -> bool:
    """IsFaceVertexSet: the set equals its own support closure (support-closed)."""
    return set(perms) == face_closure(n, perms)
