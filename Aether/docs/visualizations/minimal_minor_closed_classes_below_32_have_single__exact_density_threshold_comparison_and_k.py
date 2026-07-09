from __future__ import annotations

from fractions import Fraction
from typing import Dict, List, Tuple

Edge = Tuple[int, int]


def spanning_tree_extension(n: int, forest_edges: List[Edge]) -> List[Edge]:
    """Extend a forest on vertices {0,...,n-1} to a spanning tree via union-find.

    Greedily adds edges of the complete graph that do not close a cycle until the
    structure is connected, certifying the forest edge bound |E| <= n - 1.
    Returns the spanning tree's edge list (length exactly n - 1 when n >= 1).
    Complexity: O((n + |E|) * alpha(n)) with path-compressed union-find.
    """
    parent: List[int] = list(range(n))

    def find(x: int) -> int:
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x

    def union(a: int, b: int) -> bool:
        ra, rb = find(a), find(b)
        if ra == rb:
            return False
        parent[ra] = rb
        return True

    tree: List[Edge] = []
    for a, b in forest_edges:          # absorb the existing acyclic edges
        if union(a, b):
            tree.append((a, b))
    for a in range(n):                 # close up into a single spanning tree
        for b in range(a + 1, n):
            if len(tree) == max(n - 1, 0):
                return tree
            if union(a, b):
                tree.append((a, b))
    return tree


def density_threshold_check(n: int, num_edges: int) -> Tuple[Fraction, bool, bool]:
    """Exact edge density and the two threshold comparisons (< 1 and < 3/2).

    Returns (rho, below_one, below_three_halves) using exact rational arithmetic.
    Complexity: O(1).
    """
    rho = Fraction(0) if n == 0 else Fraction(num_edges, n)
    return rho, rho < 1, rho < Fraction(3, 2)


def is_forest_acyclic(n: int, edges: List[Edge]) -> bool:
    """Union-find acyclicity test: True iff (n, edges) is a forest (K3-minor-free).

    Equivalent to excluding K3 as a minor. Complexity: O((n + |E|) * alpha(n)).
    """
    parent: List[int] = list(range(n))

    def find(x: int) -> int:
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x

    for a, b in edges:
        ra, rb = find(a), find(b)
        if ra == rb:
            return False          # this edge closes a cycle -> K3 minor present
        parent[ra] = rb
    return True
