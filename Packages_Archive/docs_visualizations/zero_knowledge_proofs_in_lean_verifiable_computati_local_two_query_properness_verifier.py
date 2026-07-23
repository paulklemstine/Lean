from typing import Dict, List, Tuple

Edge = Tuple[int, int]
Colouring = Dict[int, int]

def local_check(c: Colouring, e: Edge) -> bool:
    u, v = e
    return c[u] != c[v]

def global_check(edges: List[Edge], c: Colouring) -> bool:
    return all(local_check(c, e) for e in edges)
