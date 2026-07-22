from itertools import combinations
from typing import Dict, Set, Tuple

def triangle_witnesses(graph: Dict[int, Set[int]]) -> Dict[int, Tuple[int, int]]:
    result: Dict[int, Tuple[int, int]] = {}
    for v, neighbors in graph.items():
        for a, b in combinations(sorted(neighbors), 2):
            if b in graph[a]:
                result[v] = (a, b)
                break
    return result
