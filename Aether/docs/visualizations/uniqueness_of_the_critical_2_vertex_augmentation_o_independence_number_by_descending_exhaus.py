from itertools import combinations
from typing import Dict, Iterable, Set

Graph = Dict[int, Set[int]]


def is_independent(graph: Graph, subset: Iterable[int]) -> bool:
    s = list(subset)
    for u, v in combinations(s, 2):
        if v in graph.get(u, set()):
            return False
    return True


def independence_number(graph: Graph) -> int:
    """Maximum independent set size by descending exhaustive search (small graphs)."""
    vertices = list(graph.keys())
    for size in range(len(vertices), 0, -1):
        for subset in combinations(vertices, size):
            if is_independent(graph, subset):
                return size
    return 0
