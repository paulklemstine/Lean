from itertools import combinations
from typing import FrozenSet, List, Set

Vertex = int
Face = FrozenSet[Vertex]


def is_flag(faces: Set[Face]) -> bool:
    """
    Decide whether an abstract simplicial complex (given by its downward-closed
    face set) is flag.

    By the Recognition Theorem, K is flag iff K equals the clique complex of its
    own 1-skeleton. Since K is always a SUBSET of that clique complex (downward
    closure), it suffices to check the reverse inclusion: every clique of the
    1-skeleton is a face. We therefore search for a 'hollow simplex' -- a clique
    of the skeleton that is missing from K. Complexity is dominated by clique
    enumeration of the 1-skeleton.
    """
    # 1-skeleton: vertices = singletons, edges = 2-faces
    verts = sorted(next(iter(f)) for f in faces if len(f) == 1)
    edges = {f for f in faces if len(f) == 2}

    def adj(a: Vertex, b: Vertex) -> bool:
        return a != b and frozenset((a, b)) in edges

    # A set is a clique of the skeleton iff all its pairs are edges.
    def is_skel_clique(s: FrozenSet[Vertex]) -> bool:
        return all(adj(a, b) for a, b in combinations(sorted(s), 2))

    # Search all subsets for a hollow simplex (clique not present as a face).
    for r in range(2, len(verts) + 1):
        for combo in combinations(verts, r):
            s = frozenset(combo)
            if is_skel_clique(s) and s not in faces:
                return False  # hollow simplex certificate
    return True
