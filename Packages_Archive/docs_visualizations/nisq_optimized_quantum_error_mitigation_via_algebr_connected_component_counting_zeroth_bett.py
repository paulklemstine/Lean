from typing import Dict, List, Sequence, Set, Tuple


def beta0(vertices: Sequence[int], edges: Set[Tuple[int, int]]) -> int:
    """Zeroth Betti number: the number of connected components of the graph
    whose vertices are `vertices` and whose adjacency relation is `edges`.

    Components are the classes of the reflexive-symmetric-transitive closure
    of the relation, computed here by weighted-free union-find with path
    compression. Near-linear time: O((V + E) * alpha(V)).
    """
    parent: Dict[int, int] = {v: v for v in vertices}

    def find(x: int) -> int:
        while parent[x] != x:
            parent[x] = parent[parent[x]]   # path compression
            x = parent[x]
        return x

    def union(a: int, b: int) -> None:
        ra, rb = find(a), find(b)
        if ra != rb:
            parent[ra] = rb

    for a, b in edges:
        union(a, b)
    return len({find(v) for v in vertices})
