from __future__ import annotations
from itertools import combinations

Graph = tuple[int, frozenset[frozenset[int]]]


def add_edge(graph: Graph, u: int, v: int) -> Graph:
    """G + uv: add the edge between u and v."""
    n, edges = graph
    return (n, edges | {frozenset((u, v))})


def contract_edge(graph: Graph, u: int, v: int) -> Graph:
    """G / uv: merge v into u, re-route v-edges to u, relabel to 0..n-2."""
    n, edges = graph
    merged: set[frozenset[int]] = set()
    for e in edges:
        a, b = tuple(e)
        a = u if a == v else a
        b = u if b == v else b
        if a != b:
            merged.add(frozenset((a, b)))
    survivors = sorted(x for x in range(n) if x != v)
    relabel = {old: new for new, old in enumerate(survivors)}
    out = frozenset(
        frozenset((relabel[a], relabel[b]))
        for e in merged for a, b in [tuple(e)]
    )
    return (n - 1, out)


def chromatic_polynomial(graph: Graph, k: int) -> int:
    """P(G, k) by deletion-contraction: P(G)=P(G+uv)+P(G/uv) (u !~ v)."""
    n, edges = graph
    if len(edges) == n * (n - 1) // 2:          # complete graph base case
        result = 1
        for i in range(n):
            result *= max(k - i, 0)
        return result
    for u, v in combinations(range(n), 2):       # pick a non-adjacent pair
        if frozenset((u, v)) not in edges:
            return (chromatic_polynomial(add_edge(graph, u, v), k)
                    + chromatic_polynomial(contract_edge(graph, u, v), k))
    return 1
