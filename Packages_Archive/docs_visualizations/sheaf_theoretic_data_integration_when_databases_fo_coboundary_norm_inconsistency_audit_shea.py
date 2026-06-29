from typing import Dict, List, Optional, Tuple

Pos = Tuple[int, int]
PartialDB = Dict[Pos, Optional[int]]

def disagreement_at(db1: PartialDB, db2: PartialDB, p: Pos) -> int:
    v1, v2 = db1.get(p), db2.get(p)
    return 1 if (v1 is not None and v2 is not None and v1 != v2) else 0

def coboundary_norm(dbs: List[PartialDB], grid: List[Pos]) -> int:
    return sum(disagreement_at(a, b, p)
               for a in dbs for b in dbs for p in grid)

def is_gluable(dbs: List[PartialDB], grid: List[Pos]) -> bool:
    return coboundary_norm(dbs, grid) == 0
