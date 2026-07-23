from typing import Dict, Iterable, List, Set, Tuple

def spectral_modular_signature(n: int, edges: Iterable[Tuple[int, int]]) -> int:
    """Compute specModSig(G) = #connected components of a finite simple graph.

    By the component-kernel theorem this integer equals the dimension of the
    harmonic kernel of G and the nullity of its Laplacian L = D - A.

    Args:
        n: number of vertices, labeled 0 .. n-1.
        edges: iterable of undirected edges (u, v), u != v.

    Returns:
        The number of connected components (the spectral modular signature).

    Complexity:
        O((n + m) * alpha(n)) with union by rank + path compression,
        where m is the number of edges and alpha is the inverse Ackermann.
    """
    parent: List[int] = list(range(n))
    rank: List[int] = [0] * n

    def find(x: int) -> int:
        root = x
        while parent[root] != root:
            root = parent[root]
        while parent[x] != root:          # path compression
            parent[x], x = root, parent[x]
        return root

    def union(x: int, y: int) -> None:
        rx, ry = find(x), find(y)
        if rx == ry:
            return
        if rank[rx] < rank[ry]:
            rx, ry = ry, rx
        parent[ry] = rx
        if rank[rx] == rank[ry]:
            rank[rx] += 1

    for u, v in edges:
        union(u, v)

    return len({find(x) for x in range(n)})
