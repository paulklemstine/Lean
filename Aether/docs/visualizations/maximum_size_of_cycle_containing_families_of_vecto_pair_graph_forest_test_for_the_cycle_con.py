from typing import Dict, Sequence, Set, Tuple

Vector = Tuple[int, ...]
Vertex = Tuple[str, int]
Edge = Tuple[Vertex, Vertex]


def pair_graph_edges(u: Vector, v: Vector) -> Set[Edge]:
    """Distinct edges L_{u_i} -- R_{v_i} of the bipartite pair graph G(u, v)."""
    if len(u) != len(v):
        raise ValueError("vectors must have equal length")
    return {(("L", ui), ("R", vi)) for ui, vi in zip(u, v)}


def contains_cycle(u: Vector, v: Vector) -> bool:
    """Goodness test: does the pair graph G(u, v) contain a cycle?

    Union-find forest test: a graph is acyclic iff no edge connects two
    already-connected endpoints.  O(b^2 * inverse-Ackermann) after dedup.
    """
    parent: Dict[Vertex, Vertex] = {}

    def find(x: Vertex) -> Vertex:
        parent.setdefault(x, x)
        root = x
        while parent[root] != root:
            root = parent[root]
        while parent[x] != root:
            parent[x], x = root, parent[x]
        return root

    for a, b in pair_graph_edges(u, v):
        ra, rb = find(a), find(b)
        if ra == rb:
            return True
        parent[ra] = rb
    return False
