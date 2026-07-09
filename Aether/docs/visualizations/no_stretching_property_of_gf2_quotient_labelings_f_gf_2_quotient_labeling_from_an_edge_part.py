from collections import deque
from typing import Dict, FrozenSet, List, Set, Tuple

Vec = Tuple[int, ...]
Edge = FrozenSet[int]
Graph = Dict[int, Set[int]]


def xor(a: Vec, b: Vec) -> Vec:
    """Coordinate-wise XOR of two GF(2) vectors."""
    return tuple((x ^ y) for x, y in zip(a, b))


def unit(i: int, t: int) -> Vec:
    """The i-th standard basis vector e_i in GF(2)^t."""
    return tuple(1 if j == i else 0 for j in range(t))


def gf2_rank(rows: List[Vec]) -> int:
    """Rank over GF(2) via Gaussian elimination."""
    basis: List[Vec] = []
    for row in rows:
        cur = row
        for b in basis:
            lead = next((i for i, v in enumerate(b) if v), None)
            if lead is not None and cur[lead]:
                cur = xor(cur, b)
        if any(cur):
            basis.append(cur)
    return len(basis)


def quotient_labeling(
    adj: Graph, edge_class: Dict[Edge, int], t: int
) -> Tuple[Dict[int, Vec], int]:
    """
    Build the GF(2)^t quotient labeling from an edge partition and return
    (labels, dim Q) where dim Q = t - rank(A) is the quotient dimension.
    """
    root = next(iter(adj))
    zero = tuple(0 for _ in range(t))
    labels: Dict[int, Vec] = {root: zero}
    tree: Set[Edge] = set()
    q = deque([root])
    while q:
        u = q.popleft()
        for w in adj[u]:
            e = frozenset({u, w})
            if w not in labels:
                labels[w] = xor(labels[u], unit(edge_class[e], t))
                tree.add(e)
                q.append(w)
    cycle_rows: List[Vec] = []
    for u in adj:
        for w in adj[u]:
            if u < w and frozenset({u, w}) not in tree:
                e = frozenset({u, w})
                cycle_rows.append(xor(xor(labels[u], labels[w]),
                                      unit(edge_class[e], t)))
    return labels, t - gf2_rank(cycle_rows)
