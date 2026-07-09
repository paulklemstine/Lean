from itertools import combinations, product
from typing import Dict, List, Set, Tuple

Graph = Dict[int, Set[int]]
Labeling = Dict[int, int]


def min_degree(g: Graph) -> int:
    return min((len(g[v]) for v in g), default=0)


def is_strdf(g: Graph, f: Labeling) -> bool:
    if any(f[v] not in (-1, 1, 2) for v in g):
        return False
    if any(sum(f[u] for u in g[v]) < 1 for v in g):
        return False
    return all(f[v] != -1 or any(f[u] == 2 for u in g[v]) for v in g)


def is_family(g: Graph, family: List[Labeling]) -> bool:
    if any(not is_strdf(g, f) for f in family):
        return False
    return all(sum(f[v] for f in family) <= 1 for v in g)


def domatic_number(g: Graph) -> int:
    """Exact d_stR(G) by bounded brute-force search, using d_stR <= delta(G)."""
    verts: List[int] = sorted(g)
    strdfs: List[Labeling] = [
        dict(zip(verts, c))
        for c in product((-1, 1, 2), repeat=len(verts))
        if is_strdf(g, dict(zip(verts, c)))
    ]
    if not strdfs:
        return 0
    ceiling: int = min_degree(g)
    best: int = 0
    for k in range(1, min(ceiling, len(strdfs)) + 1):
        if any(is_family(g, list(sub)) for sub in combinations(strdfs, k)):
            best = k
        else:
            break
    return best
