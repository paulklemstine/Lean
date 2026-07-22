from __future__ import annotations
from itertools import combinations
from typing import Dict, List, Set, FrozenSet, Tuple

def total_graph(verts: List, edges: Set[FrozenSet]
                ) -> Tuple[List, Dict[object, Set]]:
    """Total graph T(H): vertices + edges of H with the three adjacency rules."""
    tv = [("V", v) for v in verts] + [("E", e) for e in edges]
    adj: Dict[object, Set] = {x: set() for x in tv}
    def link(a, b): adj[a].add(b); adj[b].add(a)
    el = list(edges)
    for e in el:
        u, w = tuple(e); link(("V", u), ("V", w))
    for e in el:
        for u in e: link(("V", u), ("E", e))
    for e, f in combinations(el, 2):
        if e & f: link(("E", e), ("E", f))
    return tv, adj

def star_clique_bound(verts: List, edges: Set[FrozenSet], w) -> int:
    """Certify the closed-star clique at w and return the bound deg(w)+1."""
    _, adj = total_graph(verts, edges)
    star = [("V", w)] + [("E", e) for e in edges if w in e]
    assert all(b in adj[a] for a, b in combinations(star, 2)), "star not a clique"
    return len(star)  # = deg_H(w) + 1  <=  chi''(H)
