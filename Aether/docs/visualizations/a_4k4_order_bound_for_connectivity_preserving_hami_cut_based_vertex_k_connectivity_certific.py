from __future__ import annotations

from itertools import combinations, permutations
from typing import Dict, FrozenSet, List, Optional, Set

Graph = Dict[int, Set[int]]
Edge = FrozenSet[int]


def induced_connected(g: Graph, keep: Set[int]) -> bool:
    """Return True iff the induced subgraph G[keep] is connected."""
    nodes: List[int] = sorted(keep)
    if not nodes:
        return True
    seen: Set[int] = {nodes[0]}
    stack: List[int] = [nodes[0]]
    while stack:
        x = stack.pop()
        for y in g[x]:
            if y in keep and y not in seen:
                seen.add(y)
                stack.append(y)
    return len(seen) == len(nodes)


def is_k_connected(g: Graph, k: int) -> bool:
    """
    Cut-based vertex k-connectivity:
      k < |V|  and for every vertex set S with |S| < k, G[V \\ S] is connected.
    Complexity: O( sum_{i<k} C(n, i) * (n + m) ) cut checks; exponential in k.
    """
    verts: List[int] = sorted(g)
    n: int = len(verts)
    if not k < n:
        return False
    for size in range(k):
        for s in combinations(verts, size):
            if not induced_connected(g, set(verts) - set(s)):
                return False
    return True


def delete_path_edges(g: Graph, path: List[int]) -> Graph:
    """Return G - E(P) for a path given as a vertex sequence."""
    edges: Set[Edge] = {frozenset((path[i], path[i + 1]))
                        for i in range(len(path) - 1)}
    h: Graph = {v: set(g[v]) for v in g}
    for e in edges:
        a, b = tuple(e)
        h[a].discard(b)
        h[b].discard(a)
    return h


def find_connectivity_preserving_path(
    g: Graph, u: int, v: int, k: int
) -> Optional[List[int]]:
    """
    Search for a Hamiltonian u--v path P such that G - E(P) is k-connected
    (the conclusion of Conjecture_4k4). Returns the path, or None if none exists.

    Strategy: enumerate Hamiltonian u--v paths; for each, delete its edges and
    test k-connectivity of the residual graph with `is_k_connected`. The degree
    half of k-connectivity is guaranteed by the proved survival bound
    (delta >= 2k+1) whenever the 4k+4 hypotheses hold, so the search effectively
    probes only the open *cut* condition.
    """
    verts: List[int] = sorted(g)
    others: List[int] = [w for w in verts if w not in (u, v)]
    for mid in permutations(others):
        path: List[int] = [u, *mid, v]
        if all(b in g[a] for a, b in zip(path, path[1:])):
            if is_k_connected(delete_path_edges(g, path), k):
                return path
    return None
