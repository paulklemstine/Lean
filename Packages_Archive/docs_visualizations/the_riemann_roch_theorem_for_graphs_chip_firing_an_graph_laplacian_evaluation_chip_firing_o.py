from typing import Dict, List

Vertex = int
Divisor = Dict[Vertex, int]
FiringPattern = Dict[Vertex, int]

def laplacian(
    f: FiringPattern,
    vertices: List[Vertex],
    adjacency: Dict[Vertex, List[Vertex]],
) -> Divisor:
    """(lap f)(v) = sum_{u ~ v} (f[v] - f[u])."""
    return {
        v: sum(f.get(v, 0) - f.get(u, 0) for u in adjacency[v])
        for v in vertices
    }
