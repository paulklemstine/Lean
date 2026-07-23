from collections import deque
from typing import Dict, Set
Vertex = int
Graph = Dict[Vertex, Set[Vertex]]
FiringPattern = Dict[Vertex, int]

def is_kernel_pattern_constant(g: Graph, f: FiringPattern) -> bool:
    """Discrete maximum principle: on a connected graph a silent (kernel)
    firing pattern must be constant. We verify this by flooding the argmax
    level set across tying edges; if it fills the graph, f is constant on a
    kernel pattern."""
    m = max(f.values())
    start = next(v for v in g if f[v] == m)
    level: Set[Vertex] = {start}
    queue = deque([start])
    while queue:
        v = queue.popleft()
        for u in g[v]:
            if f[u] == m and u not in level:
                level.add(u)
                queue.append(u)
    return level == set(g.keys())
