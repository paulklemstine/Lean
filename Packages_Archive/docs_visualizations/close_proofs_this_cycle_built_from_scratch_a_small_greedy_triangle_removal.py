from itertools import combinations


def triangles(n: int, edges: set[frozenset]) -> list[tuple[int, int, int]]:
    out = []
    for a, b, c in combinations(range(n), 3):
        if {frozenset((a, b)), frozenset((a, c)), frozenset((b, c))} <= edges:
            out.append((a, b, c))
    return out


def greedy_triangle_removal(n: int, edges: set[frozenset]) -> tuple[set[frozenset], int]:
    """Return a triangle-free subgraph and the number of deleted edges.

    Certificate: deletions <= number of triangles in the input graph.
    """
    edges = set(edges)
    removed = 0
    while True:
        tri = triangles(n, edges)
        if not tri:
            return edges, removed
        a, b, _ = tri[0]
        edges.discard(frozenset((a, b)))  # delete one edge per triangle
        removed += 1
