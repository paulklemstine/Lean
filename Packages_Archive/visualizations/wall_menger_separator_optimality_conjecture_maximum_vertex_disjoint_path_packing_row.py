from typing import List, Tuple

Vertex = Tuple[int, int]  # (row, col)


def row_paths(m: int, n: int) -> List[List[Vertex]]:
    """
    Return a maximum packing of pairwise vertex-disjoint left-to-right paths in
    the (m+1)x(n+1) grid: the m+1 horizontal rows. Path i visits
    (i,0),(i,1),...,(i,n). Provably maximum (= m+1).
    Time: O((m+1)(n+1)) to materialize all paths.
    """
    return [[(i, j) for j in range(n + 1)] for i in range(m + 1)]


def max_disjoint_paths_value(m: int, n: int) -> int:
    """The maximum number of vertex-disjoint A-B paths: m+1."""
    return m + 1
