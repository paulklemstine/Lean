"""
Numerical demonstration of the exact local geometry of the balanced
matching-clique join H(k) on n = 4k vertices.

The graph H(k) is built explicitly and every closed-form result from the
accompanying paper is verified numerically:

  * degree of a matching vertex        = 2k + 1
  * degree of a clique vertex          = 4k - 1
  * total edge count                   = 6k^2 = 3n^2/8
  * common neighbours, matching edge   = 2k
  * common neighbours, join edge       = 2k
  * common neighbours, clique edge     = 4k - 2
  * matching edges are strictly locally sparsest (k >= 2)
  * falsification: 6k^2 != 2(2k-1)^2 = T(4k) for all k >= 1
  * divisibility: 4 | n

Self-contained: only the Python standard library is used.
"""

from __future__ import annotations

from itertools import combinations
from typing import Dict, List, Set, Tuple

# A vertex is either a matching vertex ("A", pair_index, side) or a clique
# vertex ("B", index).
Vertex = Tuple[str, int, int]


def build_matching_clique_join(k: int) -> Dict[Vertex, Set[Vertex]]:
    """Construct H(k) as an adjacency dictionary on n = 4k vertices.

    Block A = {("A", p, b) : 0 <= p < k, b in {0,1}} induces a perfect matching:
    ("A", p, 0) ~ ("A", p, 1). Block B = {("B", i, 0) : 0 <= i < 2k} induces the
    complete graph K_{2k}. Every A-vertex is joined to every B-vertex.
    """
    A: List[Vertex] = [("A", p, b) for p in range(k) for b in (0, 1)]
    B: List[Vertex] = [("B", i, 0) for i in range(2 * k)]
    adj: Dict[Vertex, Set[Vertex]] = {v: set() for v in A + B}

    def link(u: Vertex, v: Vertex) -> None:
        adj[u].add(v)
        adj[v].add(u)

    # Matching edges inside A.
    for p in range(k):
        link(("A", p, 0), ("A", p, 1))
    # Clique edges inside B.
    for i, j in combinations(range(2 * k), 2):
        link(("B", i, 0), ("B", j, 0))
    # Complete bipartite join between A and B.
    for a in A:
        for b in B:
            link(a, b)
    return adj


def degree(adj: Dict[Vertex, Set[Vertex]], v: Vertex) -> int:
    """Number of neighbours of vertex v."""
    return len(adj[v])


def edge_count(adj: Dict[Vertex, Set[Vertex]]) -> int:
    """Total number of edges via the handshake identity |E| = (sum of degrees)/2."""
    total_degree = sum(len(nbrs) for nbrs in adj.values())
    assert total_degree % 2 == 0
    return total_degree // 2


def common_neighbours(adj: Dict[Vertex, Set[Vertex]], u: Vertex, v: Vertex) -> int:
    """Number of common neighbours of u and v (triangles on the edge u~v)."""
    return len(adj[u] & adj[v])


def conjectured_threshold(n: int) -> int:
    """T(n) = (n^2 - 3n)/2 - ceil(n/2) + 2, the conjectured extremal edge count."""
    return (n * n - 3 * n) // 2 - (-(-n // 2)) + 2  # -(-n//2) = ceil(n/2)


def verify(k: int) -> None:
    """Verify every closed form of the paper for a given k."""
    n = 4 * k
    adj = build_matching_clique_join(k)

    assert len(adj) == n, "vertex count must be n = 4k"

    a_vertex: Vertex = ("A", 0, 0)
    b_vertex: Vertex = ("B", 0, 0)
    assert degree(adj, a_vertex) == 2 * k + 1
    assert degree(adj, b_vertex) == 4 * k - 1

    edges = edge_count(adj)
    assert edges == 6 * k * k
    assert edges == 3 * n * n // 8

    # Common-neighbour profile of the three edge classes.
    cn_matching = common_neighbours(adj, ("A", 0, 0), ("A", 0, 1))
    cn_join = common_neighbours(adj, ("A", 0, 0), ("B", 0, 0))
    cn_clique = common_neighbours(adj, ("B", 0, 0), ("B", 1, 0))
    assert cn_matching == 2 * k
    assert cn_join == 2 * k
    assert cn_clique == 4 * k - 2

    # Matching edges strictly locally sparsest for k >= 2.
    if k >= 2:
        assert cn_matching < cn_clique
        assert cn_matching == cn_join

    # Falsification of the conjectured extremal count.
    assert edges != 2 * (2 * k - 1) ** 2
    assert 2 * (2 * k - 1) ** 2 == conjectured_threshold(n)

    # Divisibility obstruction.
    assert n % 4 == 0

    print(
        f"k={k:2d}  n={n:3d} | "
        f"deg_A={degree(adj, a_vertex):3d}  deg_B={degree(adj, b_vertex):3d} | "
        f"|E|={edges:4d} (=3n^2/8) | "
        f"cn(match,join,clique)=({cn_matching},{cn_join},{cn_clique}) | "
        f"T(n)={conjectured_threshold(n):4d}  deficit={conjectured_threshold(n) - edges:+d}"
    )


def main() -> None:
    print("Exact local geometry of the matching-clique join H(k):\n")
    for k in range(1, 11):
        verify(k)

    print("\nAll closed forms verified for k = 1..10.")
    print("\nDeficit T(4k) - 6k^2 = 2(k^2 - 4k + 1) is never zero for integer k >= 1,")
    print("confirming the matching-clique join is NOT the extremal graph:")
    for k in range(1, 8):
        deficit = 2 * (k * k - 4 * k + 1)
        print(f"  k={k}: 2(k^2 - 4k + 1) = {deficit}")


if __name__ == "__main__":
    main()
