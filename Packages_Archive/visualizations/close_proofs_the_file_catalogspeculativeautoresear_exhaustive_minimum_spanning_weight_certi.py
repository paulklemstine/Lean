from itertools import combinations
from typing import List, Tuple

Edge = Tuple[int, int, int]

def spans(n: int, edges: List[Edge], subset: Tuple[int, ...]) -> bool:
    label = list(range(n))
    def rep(x: int) -> int:
        while label[x] != x:
            label[x] = label[label[x]]; x = label[x]
        return x
    for i in subset:
        u, v, _ = edges[i]; label[rep(u)] = rep(v)
    return len({rep(v) for v in range(n)}) == 1

def min_spanning_weight(n: int, edges: List[Edge]) -> int:
    best = None
    for r in range(n - 1, len(edges) + 1):
        for s in combinations(range(len(edges)), r):
            if spans(n, edges, s):
                w = sum(edges[i][2] for i in s)
                best = w if best is None else min(best, w)
    assert best is not None
    return best
