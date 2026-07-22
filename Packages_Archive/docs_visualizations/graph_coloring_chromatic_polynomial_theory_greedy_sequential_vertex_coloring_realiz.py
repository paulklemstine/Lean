from typing import Dict, List, Set, Tuple, FrozenSet

Edge = FrozenSet[int]
Graph = Tuple[int, FrozenSet[Edge]]


def adjacency(graph: Graph) -> Dict[int, Set[int]]:
    n, edges = graph
    adj: Dict[int, Set[int]] = {v: set() for v in range(n)}
    for e in edges:
        a, b = tuple(e)
        adj[a].add(b)
        adj[b].add(a)
    return adj


def greedy_coloring(graph: Graph, order: List[int] | None = None) -> Dict[int, int]:
    """Greedy coloring realizing chi(G) <= Delta(G) + 1.

    For each vertex in `order`, assign the smallest color not used by any
    already-colored neighbor. Since a vertex has at most Delta neighbors, a
    color in {0, ..., Delta} is always free (colorable_maxDegree_add_one).
    """
    n, _ = graph
    adj = adjacency(graph)
    if order is None:
        order = list(range(n))
    color: Dict[int, int] = {}
    for v in order:
        used = {color[w] for w in adj[v] if w in color}
        c = 0
        while c in used:
            c += 1
        color[v] = c
    return color


def colors_used(coloring: Dict[int, int]) -> int:
    return 1 + max(coloring.values(), default=-1)
