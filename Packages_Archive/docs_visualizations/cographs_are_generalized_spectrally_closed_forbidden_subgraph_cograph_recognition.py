from __future__ import annotations
from itertools import combinations, permutations

def contains_induced_p4(n: int, edges: set[frozenset[int]]) -> bool:
    """Return True iff the n-vertex graph contains an induced P4.
    Complexity: O(n^4) subsets times O(1) pattern checks."""
    for quad in combinations(range(n), 4):
        idx = {v: i for i, v in enumerate(quad)}
        deg = [0, 0, 0, 0]
        m = 0
        for u, v in combinations(quad, 2):
            if frozenset((u, v)) in edges:
                deg[idx[u]] += 1
                deg[idx[v]] += 1
                m += 1
        # An induced P4 has exactly 3 edges and degree sequence (1,1,2,2).
        if m == 3 and sorted(deg) == [1, 1, 2, 2]:
            return True
    return False

def is_cograph(n: int, edge_list: list[tuple[int, int]]) -> bool:
    return not contains_induced_p4(n, {frozenset(e) for e in edge_list})
