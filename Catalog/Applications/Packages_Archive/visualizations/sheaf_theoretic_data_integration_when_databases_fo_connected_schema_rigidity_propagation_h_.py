from collections import deque
from typing import Dict, Hashable, List

Graph = Dict[Hashable, List[Hashable]]

def propagate_from_vertex(graph: Graph, base: Hashable,
                          value: Hashable) -> Dict[Hashable, Hashable]:
    """Reconstruct the constant global section on the component of `base`
    from a single value (connected rigidity)."""
    f: Dict[Hashable, Hashable] = {base: value}
    q = deque([base])
    while q:
        v = q.popleft()
        for w in graph[v]:
            if w not in f:
                f[w] = value
                q.append(w)
    return f