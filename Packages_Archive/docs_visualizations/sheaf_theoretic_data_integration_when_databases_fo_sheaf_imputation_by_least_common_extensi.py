from itertools import combinations
from typing import Dict, Iterable, List, Optional, Tuple

Pos = Tuple[int, int]
PartialDB = Dict[Pos, Optional[int]]


def sheaf_impute(dbs: List[PartialDB], grid: Iterable[Pos]) -> Optional[PartialDB]:
    """Sheaf imputation by least common extension.

    1. Verify the sheaf condition by checking every pair agrees on overlaps.
    2. If it holds, return the colimit (the canonical least common extension).
    3. If it fails, return None: the failing pair localizes a genuine
       contradiction that no consistent imputation can resolve.

    Complexity: O(k^2 * |grid|) for the pairwise check, O(k * |grid|) for merge.
    """
    cells = list(grid)
    for a, b in combinations(dbs, 2):
        for p in cells:
            va, vb = a.get(p), b.get(p)
            if va is not None and vb is not None and va != vb:
                return None  # sheaf condition violated: no consistent merge
    out: PartialDB = {}
    for p in cells:
        out[p] = None
        for db in dbs:
            v = db.get(p)
            if v is not None:
                out[p] = v
                break
    return out
