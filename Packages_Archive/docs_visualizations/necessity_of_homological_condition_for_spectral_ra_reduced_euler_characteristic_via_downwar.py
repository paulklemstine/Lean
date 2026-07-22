from itertools import combinations
from typing import FrozenSet, Iterable, Set

Face = FrozenSet[int]
Complex = Set[Face]


def downward_closure(facets: Iterable[Iterable[int]]) -> Complex:
    """Build the full closed complex from generating facets (incl. empty face)."""
    faces: Complex = {frozenset()}
    for facet in facets:
        verts = tuple(facet)
        for k in range(len(verts) + 1):
            for sub in combinations(verts, k):
                faces.add(frozenset(sub))
    return faces


def reduced_euler(faces: Complex) -> int:
    """Reduced Euler characteristic: sum over all faces of (-1)^(|F|+1)."""
    return sum((-1) ** (len(F) + 1) for F in faces)
