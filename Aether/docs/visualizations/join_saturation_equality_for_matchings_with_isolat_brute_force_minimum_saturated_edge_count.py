from __future__ import annotations
from itertools import combinations, permutations
from typing import FrozenSet, Iterator, Tuple

Edge = FrozenSet[int]
Graph = Tuple[int, FrozenSet[Edge]]


def all_pairs(n: int) -> Iterator[Edge]:
    for i, j in combinations(range(n), 2):
        yield frozenset((i, j))


def contains_copy(host: Graph, pattern: Graph) -> bool:
    """True iff `pattern` embeds into `host` as a subgraph (injective, edge-preserving)."""
    hn, _ = host
    pn, pedges = pattern
    if pn > hn:
        return False
    adj = {(min(e), max(e)) for e in host[1]}
    for perm in permutations(range(hn), pn):
        if all((min(perm[a], perm[b]), max(perm[a], perm[b])) in adj
               for e in pedges for a, b in [tuple(e)]):
            return True
    return False


def is_saturated(host: Graph, pattern: Graph) -> bool:
    """Definition 2: pattern-free, and every nonedge addition creates a copy of pattern."""
    if contains_copy(host, pattern):
        return False
    existing = host[1]
    n = host[0]
    for e in all_pairs(n):
        if e in existing:
            continue
        if not contains_copy((n, existing | {e}), pattern):
            return False
    return True


def sat_number(n: int, pattern: Graph) -> int:
    """sat(n, pattern): minimum edge count over pattern-saturated graphs on n vertices."""
    pairs = list(all_pairs(n))
    best = -1
    for mask in range(1 << len(pairs)):
        edges = frozenset(pairs[k] for k in range(len(pairs)) if (mask >> k) & 1)
        g = (n, edges)
        if is_saturated(g, pattern):
            ec = len(edges)
            if best == -1 or ec < best:
                best = ec
    return best
