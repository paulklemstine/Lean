from __future__ import annotations
from typing import Dict, List, Set, Tuple

Graph = Dict[int, Set[int]]


def _edges(g: Graph) -> List[Tuple[int, int]]:
    return [(u, v) for u in g for v in g[u] if u < v]


def _add(a: List[int], b: List[int]) -> List[int]:
    n = max(len(a), len(b))
    a, b = a + [0] * (n - len(a)), b + [0] * (n - len(b))
    return [x + y for x, y in zip(a, b)]


def chromatic_polynomial(g: Graph) -> List[int]:
    """Coefficient list of chi_G(k) via deletion-contraction."""
    edges = _edges(g)
    if not edges:
        p = [0] * (len(g) + 1)
        p[len(g)] = 1
        return p
    u, v = edges[0]
    g_del = {w: set(g[w]) for w in g}
    g_del[u].discard(v); g_del[v].discard(u)
    g_con = {w: set(g[w]) for w in g if w != v}
    g_con[u].discard(v)
    for w in list(g_con):
        if v in g_con[w]:
            g_con[w].discard(v)
            if w != u:
                g_con[w].add(u); g_con[u].add(w)
    a = chromatic_polynomial(g_del)
    b = chromatic_polynomial(g_con)
    return _add(a, [-x for x in b])
