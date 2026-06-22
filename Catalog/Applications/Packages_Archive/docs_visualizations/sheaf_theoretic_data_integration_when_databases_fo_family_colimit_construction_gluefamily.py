from typing import Dict, Iterable, List, Optional, Tuple

Pos = Tuple[int, int]
PartialDB = Dict[Pos, Optional[int]]


def glue_family(dbs: List[PartialDB], grid: Iterable[Pos]) -> PartialDB:
    """Compute the colimit (least common extension) glueFamily of a family.

    At each cell, take the value of the first member that has one; leave the cell
    blank if every member leaves it blank. When the family is consistent the
    chosen member is irrelevant, and the result extends every member and is the
    least common extension. Complexity: O(k * |grid|) for k databases.
    """
    out: PartialDB = {}
    for p in grid:
        out[p] = None
        for db in dbs:
            v = db.get(p)
            if v is not None:
                out[p] = v
                break
    return out
