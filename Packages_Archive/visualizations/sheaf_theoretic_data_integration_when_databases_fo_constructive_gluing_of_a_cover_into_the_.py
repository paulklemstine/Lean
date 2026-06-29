from itertools import combinations
from typing import Dict, Hashable, Optional, Sequence

Record = Dict[Hashable, Hashable]

def glue(records: Sequence[Record]) -> Optional[Record]:
    """Unique global section over the union of the cover, or None if the
    family is not overlap-consistent (exists_unique_glue)."""
    for r_i, r_j in combinations(records, 2):
        for key in set(r_i) & set(r_j):
            if r_i[key] != r_j[key]:
                return None
    merged: Record = {}
    for r in records:
        merged.update(r)
    return merged