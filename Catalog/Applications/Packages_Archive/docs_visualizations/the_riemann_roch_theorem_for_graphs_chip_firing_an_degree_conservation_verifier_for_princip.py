from typing import Dict, List

Vertex = int

def verify_degree_zero(
    f: Dict[Vertex, int],
    vertices: List[Vertex],
    adjacency: Dict[Vertex, List[Vertex]],
) -> bool:
    """True iff the principal divisor lap(f) has total degree 0."""
    lap = {
        v: sum(f.get(v, 0) - f.get(u, 0) for u in adjacency[v])
        for v in vertices
    }
    return sum(lap.values()) == 0
