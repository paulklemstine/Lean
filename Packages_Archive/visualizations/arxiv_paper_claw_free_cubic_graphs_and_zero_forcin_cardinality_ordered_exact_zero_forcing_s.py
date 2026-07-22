from typing import Dict, Set, Tuple, List

def propagate(graph: Dict[int, Set[int]], initial: Set[int]) -> Tuple[Set[int], List[Tuple[int, int]]]:
    colored = set(initial)
    forces: List[Tuple[int, int]] = []
    while len(colored) < len(graph):
        move = next(((u, next(iter(graph[u] - colored))) for u in sorted(colored)
                     if len(graph[u] - colored) == 1), None)
        if move is None:
            break
        colored.add(move[1])
        forces.append(move)
    return colored, forces

from itertools import combinations
from typing import FrozenSet

def zero_forcing_number(graph: Dict[int, Set[int]]) -> Tuple[int, FrozenSet[int]]:
    vertices = sorted(graph)
    for k in range(len(vertices) + 1):
        for candidate in combinations(vertices, k):
            final, _ = propagate(graph, set(candidate))
            if len(final) == len(vertices):
                return k, frozenset(candidate)
    raise RuntimeError("unreachable")
