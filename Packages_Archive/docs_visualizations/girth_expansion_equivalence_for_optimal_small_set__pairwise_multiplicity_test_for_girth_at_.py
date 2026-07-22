from itertools import combinations
from typing import Dict, FrozenSet


Graph = Dict[int, FrozenSet[int]]


def girth_at_least_6(graph: Graph) -> bool:
    """
    Decide girth >= 6 (no 4-cycle) in O(|L|^2 * d) time by testing that every
    two distinct left vertices share at most one neighbor, justified by
    `no_four_cycle_iff`.
    """
    lefts = list(graph)
    for u, v in combinations(lefts, 2):
        if len(graph[u] & graph[v]) >= 2:   # two shared neighbors => 4-cycle
            return False
    return True
