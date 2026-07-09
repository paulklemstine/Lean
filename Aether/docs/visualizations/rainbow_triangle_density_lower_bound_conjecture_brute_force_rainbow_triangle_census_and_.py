from itertools import combinations
from typing import Dict, List, Tuple

Vertex = int
Color = int

def is_rainbow_triangle(adj: Dict[Vertex, Dict[Vertex, Color]],
                        a: Vertex, b: Vertex, c: Vertex) -> bool:
    """True if a,b,c are pairwise adjacent with three pairwise-distinct colors."""
    if b not in adj[a] or c not in adj[b] or c not in adj[a]:
        return False
    x, y, z = adj[a][b], adj[b][c], adj[c][a]
    return x != y and y != z and x != z

def count_rainbow_triangles(adj: Dict[Vertex, Dict[Vertex, Color]]) -> int:
    """rt(G): number of rainbow triangles by brute-force enumeration. O(n^3)."""
    verts: List[Vertex] = sorted(adj.keys())
    return sum(1 for a, b, c in combinations(verts, 3)
               if is_rainbow_triangle(adj, a, b, c))

def min_color_degree(adj: Dict[Vertex, Dict[Vertex, Color]]) -> int:
    """delta_c(G): minimum over v of the number of distinct colors at v. O(n^2)."""
    return min(len(set(adj[v].values())) for v in adj)
