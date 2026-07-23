from collections import deque
from typing import Dict, Set, Tuple
import math

Vertex = Tuple[str, int]  # ("L", l) or ("R", r)

def girth_bfs(adj: Dict[Vertex, Set[Vertex]]) -> float:
    """Shortest cycle length of an (undirected) graph via BFS from each vertex.

    Returns math.inf when the graph is acyclic. Complexity O(|V| * |E|).
    """
    best = math.inf
    for src in adj:
        dist: Dict[Vertex, int] = {src: 0}
        parent: Dict[Vertex, Vertex] = {src: src}
        q = deque([src])
        while q:
            u = q.popleft()
            for w in adj[u]:
                if w not in dist:
                    dist[w] = dist[u] + 1
                    parent[w] = u
                    q.append(w)
                elif parent[u] != w:
                    best = min(best, dist[u] + dist[w] + 1)
    return best
