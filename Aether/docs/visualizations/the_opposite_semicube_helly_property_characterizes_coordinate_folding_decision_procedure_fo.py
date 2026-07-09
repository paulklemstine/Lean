from __future__ import annotations
from typing import Dict, FrozenSet, Iterable, Optional, Tuple

Semicube = Tuple[int, bool]
Vertex = FrozenSet[int]


def semicube_consistency(family: Iterable[Semicube]
                         ) -> Tuple[bool, Optional[Vertex]]:
    """Coordinate-folding decision procedure for semicube families.

    Returns (True, witness) if the family is pairwise (hence globally)
    intersecting, where witness is the canonical common vertex; otherwise
    returns (False, None). Time O(|family|), space O(#coordinates)."""
    assignment: Dict[int, bool] = {}
    for i, b in family:
        if i in assignment:
            if assignment[i] != b:
                return False, None          # opposite pair -> inconsistent
        else:
            assignment[i] = b
    return True, frozenset(i for i, b in assignment.items() if b)
