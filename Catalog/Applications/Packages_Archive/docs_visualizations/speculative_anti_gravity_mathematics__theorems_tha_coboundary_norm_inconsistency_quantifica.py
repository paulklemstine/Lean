from typing import Dict, List, Tuple

Pos = Tuple[int, int]
PartialDB = Dict[Pos, int]


def disagreement_at(db1: PartialDB, db2: PartialDB, p: Pos) -> int:
    if p in db1 and p in db2 and db1[p] != db2[p]:
        return 1
    return 0


def coboundary_norm(dbs: List[PartialDB], n_rows: int, n_cols: int) -> int:
    total = 0
    for db1 in dbs:
        for db2 in dbs:
            for r in range(n_rows):
                for c in range(n_cols):
                    total += disagreement_at(db1, db2, (r, c))
    return total
