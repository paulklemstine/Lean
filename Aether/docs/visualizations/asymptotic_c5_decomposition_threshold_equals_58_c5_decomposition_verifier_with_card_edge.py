from __future__ import annotations
from typing import Dict, FrozenSet, List, Set

Edge = FrozenSet[int]
Graph = Set[Edge]


def is_five_cycle(s: Set[Edge]) -> bool:
    """A part is a genuine 5-cycle: 5 edges on 5 distinct degree-2 vertices,
    forming a single connected cycle."""
    if len(s) != 5:
        return False
    verts: Set[int] = set().union(*s) if s else set()
    if len(verts) != 5:
        return False
    deg: Dict[int, int] = {x: 0 for x in verts}
    adj: Dict[int, Set[int]] = {x: set() for x in verts}
    for e in s:
        a, b = tuple(e)
        deg[a] += 1; deg[b] += 1
        adj[a].add(b); adj[b].add(a)
    if any(d != 2 for d in deg.values()):
        return False
    start = next(iter(verts)); seen = {start}; stack = [start]
    while stack:
        x = stack.pop()
        for y in adj[x]:
            if y not in seen:
                seen.add(y); stack.append(y)
    return seen == verts


def verify_c5_decomposition(g: Graph, parts: List[Set[Edge]]) -> bool:
    """
    Verify that `parts` is a valid C5-decomposition of g:
      (isCycle) each part is a 5-cycle,
      (disj)    parts are pairwise edge-disjoint,
      (cover)   their union is exactly E(g).
    Fast consistency pre-check (card_edgeFinset_eq): |E(g)| must equal 5*|parts|.
    Runs in O(|E|) after the structural checks.
    """
    if len(g) != 5 * len(parts):           # card_edgeFinset_eq pre-check
        return False
    if not all(is_five_cycle(p) for p in parts):
        return False
    seen: Set[Edge] = set()
    for p in parts:
        if seen & p:                       # overlap -> not disjoint
            return False
        seen |= p
    return seen == g
