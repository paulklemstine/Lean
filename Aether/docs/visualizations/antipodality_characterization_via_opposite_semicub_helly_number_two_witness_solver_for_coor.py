from __future__ import annotations
from typing import Dict, FrozenSet, List, Optional, Tuple

Vertex = Tuple[int, ...]
Constraint = Tuple[int, int]

def helly_common_witness(F: List[Constraint], n: int) -> Optional[Vertex]:
    """
    Helly-number-2 solver for coordinate constraints on the full cube.
    Given a pairwise-consistent family F, return a single satisfying vertex,
    or None if F fixes some coordinate to two different bits.
    """
    assign: Dict[int, int] = {}
    for (i, b) in F:
        if i in assign and assign[i] != b:
            return None      # clash detected pairwise
        assign[i] = b
    return tuple(assign.get(i, 0) for i in range(n))
