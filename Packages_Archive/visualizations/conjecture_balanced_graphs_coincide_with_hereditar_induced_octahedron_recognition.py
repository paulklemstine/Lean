from itertools import combinations
from typing import Dict, Set, Tuple

Graph = Dict[int, Set[int]]


def induced_is_octahedron(g: Graph, six: Tuple[int, ...]) -> bool:
    """True iff the induced subgraph on the 6 given vertices is K_(2,2,2):
    each vertex has degree 4 within the set, and the three non-edges form a
    perfect matching covering all six vertices."""
    if any(sum(1 for w in six if w in g[v]) != 4 for v in six):
        return False
    non_edges = [(u, v) for u, v in combinations(six, 2) if v not in g[u]]
    if len(non_edges) != 3:
        return False
    covered: Set[int] = set()
    for u, v in non_edges:
        covered |= {u, v}
    return len(covered) == 6


def has_induced_octahedron(g: Graph) -> bool:
    return any(induced_is_octahedron(g, six) for six in combinations(g, 6))
