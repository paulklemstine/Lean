from itertools import combinations
from typing import Dict, List, Tuple

Pos = Tuple[int, int]
PartialDB = Dict[Pos, int]  # absent key == missing cell


def consistent_pair(db1: PartialDB, db2: PartialDB) -> bool:
    """Agree on every cell where both are observed (the overlap equalizer)."""
    return all(db1[p] == db2[p] for p in db1.keys() & db2.keys())


def sheaf_condition(dbs: List[PartialDB]) -> bool:
    """Every pair of partial databases is consistent."""
    return all(consistent_pair(a, b) for a, b in combinations(dbs, 2))
