from typing import Dict, List

Graph = Dict[int, List[int]]


def is_connected(graph: Graph) -> bool:
    """Predict a zero vs. positive spectral gap by testing connectivity (BFS).

    By the reducibility/irreducibility dichotomy: disconnected => gap 0,
    connected => gap > 0.
    """
    verts = sorted(graph)
    if not verts:
        return True
    seen = {verts[0]}
    stack = [verts[0]]
    while stack:
        x = stack.pop()
        for y in graph[x]:
            if y not in seen:
                seen.add(y)
                stack.append(y)
    return len(seen) == len(verts)
