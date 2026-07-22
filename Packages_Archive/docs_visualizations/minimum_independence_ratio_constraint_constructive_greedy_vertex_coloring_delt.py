from typing import Dict, List, Set, Tuple

Graph = Tuple[int, Set[frozenset]]


def greedy_coloring(n: int, adj: List[Set[int]],
                    order: List[int] | None = None) -> Dict[int, int]:
    """
    Greedy proper vertex coloring. Processing vertices in a fixed order, each
    vertex receives the least color not used by its already-colored neighbors.
    Guarantees a proper coloring with at most Delta+1 colors, where Delta is the
    maximum degree, in O(n + m) time (m = number of edges).
    """
    if order is None:
        order = list(range(n))
    color: Dict[int, int] = {}
    for v in order:
        used: Set[int] = {color[w] for w in adj[v] if w in color}
        c = 0
        while c in used:
            c += 1
        color[v] = c
    return color


def max_colors_used(color: Dict[int, int]) -> int:
    """Number of distinct colors used by a coloring."""
    return len(set(color.values()))
