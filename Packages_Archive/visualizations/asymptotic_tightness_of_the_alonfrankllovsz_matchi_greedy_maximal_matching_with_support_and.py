from typing import Dict, FrozenSet, List, Sequence

Edge = FrozenSet[int]
Hypergraph = List[Edge]

def greedy_maximal_matching(h: Hypergraph) -> Hypergraph:
    """Scan edges once; add an edge iff disjoint from the used-vertex set."""
    used: set[int] = set()
    m: Hypergraph = []
    for e in h:
        if not (used & e):
            m.append(e)
            used |= e
    return m

def support(edges: Sequence[Edge]) -> FrozenSet[int]:
    s: set[int] = set()
    for e in edges:
        s |= e
    return frozenset(s)

def max_degree(h: Hypergraph) -> int:
    deg: Dict[int, int] = {}
    for e in h:
        for v in e:
            deg[v] = deg.get(v, 0) + 1
    return max(deg.values(), default=0)
