from itertools import combinations
from typing import Dict, Iterable, List, Optional, Tuple

Pos = Tuple[int, int]
PartialDB = Dict[Pos, Optional[int]]


def consistent_pair(db1: PartialDB, db2: PartialDB, grid: Iterable[Pos]) -> bool:
    """Return True iff db1 and db2 agree on every cell where both are filled."""
    for p in grid:
        v1, v2 = db1.get(p), db2.get(p)
        if v1 is not None and v2 is not None and v1 != v2:
            return False
    return True


def sheaf_condition(dbs: List[PartialDB], grid: Iterable[Pos]) -> bool:
    """Return True iff every pair of partial databases is consistent."""
    cells = list(grid)
    return all(consistent_pair(a, b, cells) for a, b in combinations(dbs, 2))
