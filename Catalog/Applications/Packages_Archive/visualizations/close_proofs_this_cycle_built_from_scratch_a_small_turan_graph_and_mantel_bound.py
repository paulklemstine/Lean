from itertools import combinations
from math import floor


def turan_graph(n: int, p: int) -> set[frozenset]:
    """Edge set of the Turan graph T(n, p): i ~ j iff i % p != j % p."""
    return {
        frozenset((i, j))
        for i in range(n)
        for j in range(i + 1, n)
        if i % p != j % p
    }


def mantel_bound(n: int) -> int:
    """Maximum edges in a triangle-free graph on n vertices."""
    return floor(n * n / 4)


# T(n, 2) realises the Mantel bound exactly:
for n in range(2, 12):
    assert len(turan_graph(n, 2)) == mantel_bound(n)
