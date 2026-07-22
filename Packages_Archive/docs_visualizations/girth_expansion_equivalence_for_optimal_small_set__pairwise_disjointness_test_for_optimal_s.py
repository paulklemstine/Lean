from itertools import combinations
from typing import Dict, FrozenSet


Graph = Dict[int, FrozenSet[int]]


def is_optimal_expander_fast(graph: Graph, s: int) -> bool:
    """
    Decide s-optimal small-set expansion (s >= 2) in O(|L|^2 * d) time by
    testing pairwise disjointness of neighborhoods, justified by
    `optimal_iff_disjoint`: for s >= 2, optimality is equivalent to
    AllPairsDisjoint, independent of s.
    """
    lefts = list(graph)
    for u, v in combinations(lefts, 2):
        if graph[u] & graph[v]:        # shared neighbor => not optimal
            return False
    return True
