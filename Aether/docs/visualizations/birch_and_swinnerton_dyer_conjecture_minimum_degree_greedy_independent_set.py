from __future__ import annotations
import itertools
from typing import List, Set, Tuple

Vertex = int
Edge = Tuple[Vertex, Vertex]


def min_degree_greedy(n: int, edges: List[Edge]) -> Set[Vertex]:
    """
    Minimum-degree greedy independent set.

    Repeatedly pick a vertex of minimum degree in the remaining induced
    subgraph, add it to the independent set, and delete it with all its
    neighbors. Returns an independent set of size at least
    sum_v 1/(deg v + 1) >= n^2/(2m + n).
    """
    adj: List[Set[Vertex]] = [set() for _ in range(n)]
    for u, v in edges:
        if u != v:
            adj[u].add(v)
            adj[v].add(u)
    remaining: Set[Vertex] = set(range(n))
    result: Set[Vertex] = set()
    while remaining:
        v = min(remaining, key=lambda x: len(adj[x] & remaining))
        result.add(v)
        remaining.discard(v)
        remaining -= adj[v]
    return result
