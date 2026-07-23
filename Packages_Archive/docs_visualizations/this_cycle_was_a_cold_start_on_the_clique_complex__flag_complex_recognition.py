from itertools import combinations
from typing import Hashable, Sequence, Set, FrozenSet

Vertex = Hashable

def is_flag(vertices: Sequence[Vertex],
            faces: Set[FrozenSet[Vertex]]) -> bool:
    """Decide whether a complex is a flag complex.

    A complex is flag iff every set whose singletons AND pairs are all faces is
    itself a face. We scan candidate sets by increasing size; the first witness
    of a 'hollow' simplex (all sub-edges present, set absent) certifies non-flag."""
    fset = set(faces)
    for k in range(2, len(vertices) + 1):
        for combo in combinations(vertices, k):
            s = frozenset(combo)
            singles_ok = all(frozenset((v,)) in fset for v in s)
            pairs_ok = all(frozenset((u, v)) in fset for u, v in combinations(s, 2))
            if singles_ok and pairs_ok and s not in fset:
                return False
    return True
