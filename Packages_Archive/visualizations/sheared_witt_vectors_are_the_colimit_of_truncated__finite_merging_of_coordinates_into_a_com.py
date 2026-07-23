from __future__ import annotations
from typing import List

def merge_to_common_stage(coord_stages: List[int]) -> int:
    """
    Finite-merging lemma. Given the least stage of each of finitely many
    coordinates of the colimit ring, return a single stage containing them all.

    Complexity: O(m) in the number m of coordinates.
    """
    return max(coord_stages + [0])
