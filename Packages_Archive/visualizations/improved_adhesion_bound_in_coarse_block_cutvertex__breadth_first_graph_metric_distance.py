from collections import deque
from typing import Dict, Optional, Set, Tuple

Vertex = int
Graph = Dict[Vertex, Set[Vertex]]


def bfs_dist(g: Graph, source: Vertex, target: Vertex) -> Optional[int]:
    """Return the shortest-path graph distance from source to target.

    Runs a breadth-first search; returns None if target is unreachable.
    Time O(V + E), space O(V).
    """
    if source == target:
        return 0
    seen: Set[Vertex] = {source}
    frontier: "deque[Tuple[Vertex, int]]" = deque([(source, 0)])
    while frontier:
        node, d = frontier.popleft()
        for nbr in g.get(node, ()):
            if nbr == target:
                return d + 1
            if nbr not in seen:
                seen.add(nbr)
                frontier.append((nbr, d + 1))
    return None
