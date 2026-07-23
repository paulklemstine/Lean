from collections import deque
from typing import Dict, List, Set, Tuple

Edge = Tuple[int, int]
BitVec = Tuple[int, ...]


def gf2_row_reduce(rows: List[int]) -> List[int]:
    """Gaussian elimination over GF(2) on bitmask rows; returns a row-space basis."""
    basis: List[int] = []
    for r in rows:
        cur = r
        for b in basis:
            cur = min(cur, cur ^ b)
        if cur:
            basis.append(cur)
            basis.sort(reverse=True)
    return basis


def edge_partition_labeling(
    n: int,
    edges: List[Edge],
    edge_class: Dict[Edge, int],
    num_classes: int,
    root: int = 0,
) -> Tuple[Dict[int, BitVec], List[BitVec], int]:
    """Parity-quotient labeling of vertices from an edge partition.

    Returns (label, generators, k) where label[v] is the k-bit quotient label,
    generators are the images of the t classes (the Cayley generating set), and
    k = t - rank(A) for the cycle-class parity matrix A.
    """
    adj: Dict[int, List[int]] = {v: [] for v in range(n)}
    for u, v in edges:
        adj[u].append(v)
        adj[v].append(u)

    def class_of(u: int, v: int) -> int:
        e = (u, v) if (u, v) in edge_class else (v, u)
        return edge_class[e]

    raw: Dict[int, int] = {root: 0}
    tree: Set[Edge] = set()
    q: deque[int] = deque([root])
    while q:
        u = q.popleft()
        for w in adj[u]:
            if w not in raw:
                j = class_of(u, w)
                raw[w] = raw[u] ^ (1 << j)
                tree.add((min(u, w), max(u, w)))
                q.append(w)

    cycle_rows: List[int] = []
    for u, v in edges:
        if (min(u, v), max(u, v)) in tree:
            continue
        cycle_rows.append(raw[u] ^ raw[v] ^ (1 << class_of(u, v)))
    basis = gf2_row_reduce(cycle_rows)

    pivots = {b.bit_length() - 1 for b in basis}
    surviving = [j for j in range(num_classes) if j not in pivots]

    def reduce_mod_cycle(vec: int) -> int:
        cur = vec
        for b in basis:
            cur = min(cur, cur ^ b)
        return cur

    def to_bits(vec: int) -> BitVec:
        red = reduce_mod_cycle(vec)
        return tuple((red >> j) & 1 for j in surviving)

    label = {v: to_bits(raw[v]) for v in range(n)}
    generators = [to_bits(1 << j) for j in range(num_classes)]
    return label, generators, num_classes - len(basis)
