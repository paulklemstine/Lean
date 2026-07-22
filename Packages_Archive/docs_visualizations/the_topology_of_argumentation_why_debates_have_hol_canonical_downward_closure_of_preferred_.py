from __future__ import annotations
from itertools import combinations
from typing import FrozenSet
Face=FrozenSet[int]
def preferred_generated_complex(facets: list[Face]) -> set[Face]:
    faces: set[Face]=set()
    for facet in facets:
        ordered=sorted(facet)
        for size in range(len(ordered)+1):
            faces.update(frozenset(x) for x in combinations(ordered,size))
    return faces
