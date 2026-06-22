from __future__ import annotations
from typing import Dict, List, Optional, Tuple

Pos = Tuple[int, int]
PartialDB = Dict[Pos, Optional[int]]

def coboundary_norm(views: List[PartialDB], positions: List[Pos]) -> int:
    """
    Total number of pairwise disagreements over all cells (CoboundaryNorm).
    By coboundary_zero_iff_sheaf, this equals 0 iff the family satisfies the
    sheaf condition, i.e. iff a consistent global completion exists.
    """
    total = 0
    n = len(views)
    for i in range(n):
        for j in range(n):
            for p in positions:
                vi, vj = views[i].get(p), views[j].get(p)
                if vi is not None and vj is not None and vi != vj:
                    total += 1
    return total

def certifies_sheaf_condition(views: List[PartialDB], positions: List[Pos]) -> bool:
    """Decision procedure: consistent iff coboundary norm vanishes."""
    return coboundary_norm(views, positions) == 0
