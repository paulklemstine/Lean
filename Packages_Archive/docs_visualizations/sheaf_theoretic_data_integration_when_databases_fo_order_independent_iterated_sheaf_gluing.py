from typing import Dict, List, Optional, Tuple
Pos = Tuple[int, int]
PartialDB = Dict[Pos, Optional[int]]

def iterated_glue(dbs: List[PartialDB], positions: List[Pos]) -> PartialDB:
    glued: PartialDB = {p: None for p in positions}
    for db in dbs:
        for p in positions:
            if glued[p] is None:
                glued[p] = db.get(p)
    return glued
