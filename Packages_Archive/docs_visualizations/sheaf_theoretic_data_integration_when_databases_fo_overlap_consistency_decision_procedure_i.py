from itertools import combinations
from typing import Dict, Hashable, Optional, Sequence, Tuple

Record = Dict[Hashable, Hashable]

def consistency_witness(records: Sequence[Record]
                        ) -> Tuple[bool, Optional[Hashable]]:
    """Return (True, None) if the family is overlap-consistent (hence
    integrable by exists_glue_iff_consistent), else (False, key) with a
    witnessing conflicting key."""
    for r_i, r_j in combinations(records, 2):
        for key in set(r_i) & set(r_j):
            if r_i[key] != r_j[key]:
                return (False, key)
    return (True, None)