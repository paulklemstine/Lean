from itertools import combinations
from typing import Dict, List, Set, Tuple

def closure(adj: Dict[int, Set[int]], seed: Set[int]) -> Set[int]:
    colored = set(seed)
    changed = True
    while changed:
        changed = False
        for u in sorted(colored):
            remaining = adj[u] - colored
            if len(remaining) == 1:
                colored.add(next(iter(remaining))); changed = True; break
    return colored

def minimum_zero_forcing_set(adj: Dict[int, Set[int]]) -> Tuple[int, Set[int]]:
    vertices = sorted(adj)
    for k in range(len(vertices) + 1):
        for candidate in combinations(vertices, k):
            seed = set(candidate)
            if len(closure(adj, seed)) == len(vertices):
                return k, seed
    raise RuntimeError("unreachable")
