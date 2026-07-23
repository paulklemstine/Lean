from itertools import combinations
from typing import Dict, List, Set, Tuple

Incidence = Dict[int, Set[int]]  # left vertex -> right neighbours

def minimum_distance(inc: Incidence) -> Tuple[int, List[int]]:
    """Exact minimum distance of B(G): smallest non-empty S whose every right
    vertex has even S-degree. Enumerates left-subsets by increasing size.

    Complexity O(2^|L| * d) worst case; exact for small Tanner graphs.
    """
    rights: Set[int] = set().union(*inc.values()) if inc else set()
    left = sorted(inc)
    for size in range(1, len(left) + 1):
        for S in combinations(left, size):
            counts = {r: 0 for r in rights}
            for l in S:
                for r in inc[l]:
                    counts[r] += 1
            if all(c % 2 == 0 for c in counts.values()):
                return size, list(S)
    return 0, []
