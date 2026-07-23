from collections import deque
from typing import Callable, Dict, Hashable, List, Optional

Vertex = Hashable
Graph = Dict[Vertex, List[Vertex]]


def two_color(graph: Graph) -> Optional[Dict[Vertex, int]]:
    """Return a proper 2-coloring of `graph`, or None if it is not bipartite.

    Runs a breadth-first scan over every component, assigning alternating
    colors. A conflict (adjacent equal colors) proves an odd closed walk and
    therefore non-bipartiteness. Complexity O(V + E)."""
    color: Dict[Vertex, int] = {}
    for start in graph:
        if start in color:
            continue
        color[start] = 0
        queue: deque = deque([start])
        while queue:
            u = queue.popleft()
            for w in graph[u]:
                if w not in color:
                    color[w] = 1 - color[u]
                    queue.append(w)
                elif color[w] == color[u]:
                    return None
    return color


def pullback_coloring(
    embedding: Dict[Vertex, Vertex],
    host_coloring: Dict[Vertex, int],
) -> Dict[Vertex, int]:
    """Pull a host coloring back along an isometric map f: c'(v) = c(f(v)).

    If f is an isometry and host_coloring is proper, the result is a proper
    coloring of the source (edges map to edges under an isometry). Complexity
    O(V)."""
    return {v: host_coloring[embedding[v]] for v in embedding}
