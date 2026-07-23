from typing import Callable, List, Tuple

Readout = Tuple[bool, ...]


def betti0_agreement(s: Readout) -> int:
    """Compute the zeroth Betti number of the agreement complex of a readout.

    The agreement complex links sites i, j whenever s[i] == s[j].  Its number of
    connected components is computed by a near-linear union-find with path
    compression; for a length-n readout the cost is O(n^2 * alpha(n)) for the
    pairwise scan (or O(n) using the value-bucketing shortcut below)."""
    n = len(s)
    parent: List[int] = list(range(n))

    def find(x: int) -> int:
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x

    def union(x: int, y: int) -> None:
        rx, ry = find(x), find(y)
        if rx != ry:
            parent[rx] = ry

    for i in range(n):
        for j in range(i + 1, n):
            if s[i] == s[j]:
                union(i, j)

    return len({find(i) for i in range(n)})


def betti0_agreement_fast(s: Readout) -> int:
    """O(n) shortcut: components = number of distinct bit values present."""
    if not s:
        return 0
    return len(set(s))
