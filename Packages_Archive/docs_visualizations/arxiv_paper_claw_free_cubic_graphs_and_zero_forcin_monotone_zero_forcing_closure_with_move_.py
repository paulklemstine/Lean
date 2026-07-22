from typing import Dict, List, Set, Tuple

def forcing_closure(adjacency: Dict[int, Set[int]], seed: Set[int]) -> Tuple[Set[int], List[Tuple[int, int]]]:
    colored = set(seed)
    moves: List[Tuple[int, int]] = []
    while True:
        move = next(((u, next(iter(adjacency[u] - colored))) for u in sorted(colored)
                     if len(adjacency[u] - colored) == 1), None)
        if move is None:
            return colored, moves
        colored.add(move[1])
        moves.append(move)
