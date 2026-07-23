from itertools import combinations
from typing import Dict, FrozenSet, List, Set, Tuple

Diag = Tuple[int, int]


def crosses(d1: Diag, d2: Diag) -> bool:
    a, b = sorted(d1)
    c, d = sorted(d2)
    if {a, b} & {c, d}:
        return False
    return (a < c < b) != (a < d < b)


def is_side(i: int, j: int, m: int) -> bool:
    return (j - i) % m == 1 or (i - j) % m == 1


def all_triangulations(m: int) -> List[FrozenSet[Diag]]:
    chords = [(i, j) for i, j in combinations(range(m), 2) if not is_side(i, j, m)]
    k = m - 3
    if k == 0:
        return [frozenset()]
    out: List[FrozenSet[Diag]] = []
    for combo in combinations(chords, k):
        if all(not crosses(x, y) for x, y in combinations(combo, 2)):
            out.append(frozenset(combo))
    return out


def build_exchange_graph(m: int) -> Dict[FrozenSet[Diag], List[FrozenSet[Diag]]]:
    """Adjacency of the flip graph: two triangulations are adjacent iff they
    differ in exactly one diagonal. Vertices = Catalan(m-2); every vertex has
    degree m-3 (the (m-3)-regular 1-skeleton of the associahedron)."""
    tris = all_triangulations(m)
    tset: Set[FrozenSet[Diag]] = set(tris)
    adj: Dict[FrozenSet[Diag], List[FrozenSet[Diag]]] = {}
    for t in tris:
        adj[t] = [u for u in tset if len(t.symmetric_difference(u)) == 2]
    return adj
