from typing import Dict, List, Tuple

Edge = Tuple[int, int]
Colouring = Dict[int, int]

def catching_edges(edges: List[Edge], c: Colouring) -> List[Edge]:
    return [(u, v) for (u, v) in edges if c[u] == c[v]]

def rejection_probability(edges: List[Edge], c: Colouring) -> float:
    return len(catching_edges(edges, c)) / len(edges)
