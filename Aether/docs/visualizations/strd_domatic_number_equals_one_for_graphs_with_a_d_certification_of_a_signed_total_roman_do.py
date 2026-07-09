from itertools import product
from typing import Dict, List, Set

Graph = Dict[int, Set[int]]
Labeling = Dict[int, int]


def is_strdf(g: Graph, f: Labeling) -> bool:
    """Return True iff f is a signed total Roman dominating function on g."""
    if any(f[v] not in (-1, 1, 2) for v in g):
        return False
    for v in g:
        if sum(f[u] for u in g[v]) < 1:          # total domination
            return False
    for v in g:                                   # Roman condition
        if f[v] == -1 and not any(f[u] == 2 for u in g[v]):
            return False
    return True
