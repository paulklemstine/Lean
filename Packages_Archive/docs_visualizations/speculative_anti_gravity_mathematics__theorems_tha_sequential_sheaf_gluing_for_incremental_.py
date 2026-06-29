from typing import Dict, List, Tuple

Pos = Tuple[int, int]
PartialDB = Dict[Pos, int]


def glue(db1: PartialDB, db2: PartialDB) -> PartialDB:
    """GluingMap: prefer db1 where defined, else take db2."""
    merged: PartialDB = dict(db2)
    merged.update(db1)
    return merged


def integrate(dbs: List[PartialDB]) -> PartialDB:
    """Fold gluing across pairwise-consistent sources."""
    merged: PartialDB = {}
    for db in dbs:
        merged = glue(merged, db)
    return merged
