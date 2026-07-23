from itertools import combinations
from typing import Dict, FrozenSet, List, Optional, Set, Tuple

Graph = Dict[int, Set[int]]

def is_clique(g: Graph, s: Tuple[int, ...]) -> bool:
    return all(v in g[u] for u, v in combinations(s, 2))

def find_odd_clique_partition(gc: Graph, num_classes: int,
                              max_size: int) -> Optional[List[Tuple[int, ...]]]:
    """Backtracking search for a partition of the complement gc into exactly
    num_classes cliques, each of odd size at most max_size. Such a partition is
    precisely a conformable colouring (complement-clique identity)."""
    odd_sizes = [s for s in range(1, max_size + 1) if s % 2 == 1]

    def bt(remaining: FrozenSet[int],
           parts: List[Tuple[int, ...]]) -> Optional[List[Tuple[int, ...]]]:
        if not remaining:
            return parts if len(parts) == num_classes else None
        if len(parts) >= num_classes:
            return None
        pivot = min(remaining)
        for size in odd_sizes:
            if size > len(remaining):
                continue
            others = [u for u in remaining if u != pivot]
            for combo in combinations(others, size - 1):
                clique = (pivot,) + combo
                if is_clique(gc, clique):
                    res = bt(remaining - set(clique), parts + [clique])
                    if res is not None:
                        return res
        return None

    return bt(frozenset(gc), [])
