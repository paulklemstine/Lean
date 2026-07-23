from collections import deque
from typing import Dict, List, Optional, Tuple

Vertex = object


def bfs_distances(adj: Dict[Vertex, List[Vertex]], src: Vertex) -> Dict[Vertex, int]:
    d: Dict[Vertex, int] = {src: 0}
    q: deque = deque([src])
    while q:
        u = q.popleft()
        for w in adj[u]:
            if w not in d:
                d[w] = d[u] + 1
                q.append(w)
    return d


def refute_isometric_embedding(
    source_adj: Dict[Vertex, List[Vertex]],
    embedding: Dict[Vertex, Vertex],
    host_coloring,
) -> Optional[Tuple[Vertex, Vertex]]:
    """
    Given a map f (embedding) into a host equipped with a proper 2-coloring
    (host_coloring), pull the coloring back to the source and return a
    monochromatic source-edge if one exists. Such an edge certifies that f is
    NOT an isometric embedding (an isometric map would yield a proper coloring).
    """
    for u in source_adj:
        for v in source_adj[u]:
            if host_coloring(embedding[u]) == host_coloring(embedding[v]):
                return (u, v)
    return None
