from typing import Dict, Set
Vertex = int
Graph = Dict[Vertex, Set[Vertex]]
FiringPattern = Dict[Vertex, int]
Divisor = Dict[Vertex, int]

def lap(g: Graph, f: FiringPattern) -> Divisor:
    """Apply the graph Laplacian: (lap f)(v) = sum_{u~v} (f v - f u)."""
    return {v: sum(f[v] - f[u] for u in g[v]) for v in g}

def divisor_degree(d: Divisor) -> int:
    """Degree of a divisor = sum of its coefficients (a chip-firing invariant)."""
    return sum(d.values())
