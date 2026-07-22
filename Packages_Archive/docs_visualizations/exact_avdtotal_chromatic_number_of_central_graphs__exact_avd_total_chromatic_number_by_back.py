from __future__ import annotations
from itertools import combinations
from typing import Dict, List, Set, FrozenSet, Optional

def _total_graph(verts, edges):
    tv = [("V", v) for v in verts] + [("E", e) for e in edges]
    adj: Dict = {x: set() for x in tv}
    def link(a, b): adj[a].add(b); adj[b].add(a)
    el = list(edges)
    for e in el:
        u, w = tuple(e); link(("V", u), ("V", w))
    for e in el:
        for u in e: link(("V", u), ("E", e))
    for e, f in combinations(el, 2):
        if e & f: link(("E", e), ("E", f))
    return tv, adj

def avd_total_chromatic_number(verts: List, edges: Set[FrozenSet],
                               hi: int = 12) -> int:
    """Exact AVD-total chromatic number by increasing-k backtracking search."""
    tv, adj = _total_graph(verts, edges)
    order = sorted(tv, key=lambda x: -len(adj[x]))
    def colorset(col, v):
        s = {col[("V", v)]}
        for e in edges:
            if v in e: s.add(col[("E", e)])
        return frozenset(s)
    for k in range(1, hi + 1):
        col: Dict = {}
        def proper(x, c): return all(col.get(nb) != c for nb in adj[x])
        def avd():
            return all(colorset(col, tuple(e)[0]) != colorset(col, tuple(e)[1])
                       for e in edges)
        def bt(i: int) -> bool:
            if i == len(order): return avd()
            x = order[i]; used = max(col.values(), default=-1)
            for c in range(min(k, used + 2)):
                if proper(x, c):
                    col[x] = c
                    if bt(i + 1): return True
                    del col[x]
            return False
        if bt(0): return k
    raise RuntimeError("no AVD total colouring within bound")
