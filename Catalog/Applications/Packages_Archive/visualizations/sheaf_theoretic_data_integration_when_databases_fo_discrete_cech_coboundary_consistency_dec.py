from typing import Dict, List, Optional, Tuple
Pos = Tuple[int, int]
PartialDB = Dict[Pos, Optional[int]]

def coboundary_consistency(
    dbs: List[PartialDB], positions: List[Pos]
) -> Tuple[bool, int, List[Tuple[int, int, Pos, int, int]]]:
    norm = 0
    conflicts: List[Tuple[int, int, Pos, int, int]] = []
    for i in range(len(dbs)):
        for j in range(len(dbs)):
            for p in positions:
                vi, vj = dbs[i].get(p), dbs[j].get(p)
                if vi is not None and vj is not None and vi != vj:
                    norm += 1
                    conflicts.append((i, j, p, vi, vj))
    return norm == 0, norm, conflicts
