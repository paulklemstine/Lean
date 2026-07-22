from itertools import combinations
from typing import List, Set

def is_sidon(s: List[int]) -> bool:
    """Verify the Sidon property by testing distinctness of pairwise differences.
    Runs in O(|s|^2) time and space."""
    diffs: Set[int] = set()
    for a, b in combinations(s, 2):
        d = a - b
        if d in diffs or -d in diffs:
            return False
        diffs.add(d); diffs.add(-d)
    return True
