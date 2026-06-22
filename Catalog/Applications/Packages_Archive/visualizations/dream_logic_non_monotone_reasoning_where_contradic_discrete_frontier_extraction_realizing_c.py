from typing import List, Tuple


def discrete_frontier(member: List[bool]) -> List[int]:
    """Indices forming the discrete frontier (= contradiction set) of a closed set.

    Realizes the theorem contradiction(A) = frontier(A): a grid point is a
    coexisting contradiction iff it lies IN A and is adjacent to a point OUTSIDE A
    (it belongs to A and to the closure of the complement). O(n) over the grid.
    """
    n = len(member)
    out: List[int] = []
    for i in range(n):
        if member[i] and (
            (i > 0 and not member[i - 1]) or (i < n - 1 and not member[i + 1])
        ):
            out.append(i)
    return out


def is_clopen(member: List[bool]) -> bool:
    """A discretized set is clopen iff its frontier is empty (LNC holds)."""
    return len(discrete_frontier(member)) == 0
