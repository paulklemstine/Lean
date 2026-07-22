from typing import List, Tuple

def num_components(n_vertices: int,
                   edges: List[Tuple[int, int]]) -> int:
    parent = list(range(n_vertices))
    def find(a: int) -> int:
        while parent[a] != a:
            parent[a] = parent[parent[a]]
            a = parent[a]
        return a
    for a, b in edges:
        ra, rb = find(a), find(b)
        if ra != rb:
            parent[ra] = rb
    return len({find(i) for i in range(n_vertices)})
