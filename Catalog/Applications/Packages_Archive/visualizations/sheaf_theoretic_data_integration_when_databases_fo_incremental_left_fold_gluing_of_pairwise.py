from __future__ import annotations
from typing import Dict, List, Optional, Tuple

Pos = Tuple[int, int]
PartialDB = Dict[Pos, Optional[int]]

def consistent_pair(a: PartialDB, b: PartialDB, positions: List[Pos]) -> bool:
    """Agree wherever both are defined (ConsistentPair)."""
    for p in positions:
        va, vb = a.get(p), b.get(p)
        if va is not None and vb is not None and va != vb:
            return False
    return True

def glue_two(a: PartialDB, b: PartialDB, positions: List[Pos]) -> PartialDB:
    """GluingMap: prefer a, fall back to b."""
    out: PartialDB = {}
    for p in positions:
        va = a.get(p)
        out[p] = va if va is not None else b.get(p)
    return out

def incremental_glue(views: List[PartialDB], positions: List[Pos]) -> Optional[PartialDB]:
    """
    Fold a list of pairwise-consistent views into one merged database.
    Returns None if any pair conflicts (no global section exists).
    Justification: gluing_preserves_consistency guarantees the running merge
    stays consistent with every remaining view, so a single left fold suffices.
    """
    # Pre-check pairwise consistency (coboundary norm = 0).
    for i in range(len(views)):
        for j in range(i + 1, len(views)):
            if not consistent_pair(views[i], views[j], positions):
                return None
    merged: PartialDB = {p: None for p in positions}
    for v in views:
        merged = glue_two(merged, v, positions)
    return merged
