from typing import Dict, List, Optional, Tuple

Pos = Tuple[int, int]
PartialDB = Dict[Pos, Optional[int]]

def consistent_pair(db1: PartialDB, db2: PartialDB) -> bool:
    for p in set(db1) & set(db2):
        v1, v2 = db1.get(p), db2.get(p)
        if v1 is not None and v2 is not None and v1 != v2:
            return False
    return True

def gluing_map(db1: PartialDB, db2: PartialDB,
               grid: List[Pos]) -> PartialDB:
    assert consistent_pair(db1, db2), 'sources must be consistent'
    out: PartialDB = {}
    for p in grid:
        v1 = db1.get(p)
        out[p] = v1 if v1 is not None else db2.get(p)
    return out
