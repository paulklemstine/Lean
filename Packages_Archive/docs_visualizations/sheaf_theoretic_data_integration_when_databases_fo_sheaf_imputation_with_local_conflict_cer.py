from __future__ import annotations
from itertools import combinations
from typing import Dict, Hashable, List, Optional, Sequence, Tuple, Union

Record = Dict[Hashable, object]

def sheaf_impute(
    family: Sequence[Record],
) -> Union[Record, Tuple[str, int, int, Hashable]]:
    """Return the unique support-bounded global section, or a conflict triple.

    Step 1 (feasibility, Theorem `glue_family_exists`): all-pairs, all-columns
    compatibility scan -- sound and complete for existence of a global section.
    Step 2 (completion, `familyGlue` + `glue_unique`): greedy first-wins merge,
    the unique global section whose support is the union of the inputs' supports.
    """
    # Step 1: O(m^2 * n) feasibility certificate
    for j, k in combinations(range(len(family)), 2):
        a, b = family[j], family[k]
        for col in a.keys() & b.keys():
            if a[col] != b[col]:
                return ("CONFLICT", j, k, col)
    # Step 2: O(m * n) canonical completion (empty section is the unit)
    result: Record = {}
    for rec in family:
        for col, val in rec.items():
            result.setdefault(col, val)
    return result
