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
