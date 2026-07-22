from itertools import combinations
from typing import Dict, Iterable, Set

Vertex = int
Graph = Dict[Vertex, Set[Vertex]]


def set_diameter(g: Graph, s: Iterable[Vertex]) -> int:
    """Graph-metric diameter of a vertex set S: max over pairs of dist(u, v).

    Returns 0 for empty or singleton sets. Requires the pairs to be reachable
    (i.e. S lies in one connected component). Complexity O(|S|^2 * (V + E))
    using per-pair BFS; can be reduced with all-pairs BFS from each vertex.
    """
    from collections import deque

    def dist(a: Vertex, b: Vertex) -> int:
        if a == b:
            return 0
        seen = {a}
        fr = deque([(a, 0)])
        while fr:
            x, d = fr.popleft()
            for y in g.get(x, ()):
                if y == b:
                    return d + 1
                if y not in seen:
                    seen.add(y)
                    fr.append((y, d + 1))
        raise ValueError("set spans disconnected components")

    verts = list(s)
    return max((dist(a, b) for a, b in combinations(verts, 2)), default=0)
