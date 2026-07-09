from typing import List, Tuple

Vertex = Tuple[int, int]  # (row, col)


def column_separator(m: int, n: int, c: int) -> List[Vertex]:
    """
    Return a minimum left-to-right vertex separator of the (m+1)x(n+1) grid:
    the c-th column {(i, c) : 0 <= i <= m}. Provably of minimum size m+1.
    Time and space: O(m).
    """
    if not (0 <= c <= n):
        raise ValueError("column index c must satisfy 0 <= c <= n")
    return [(i, c) for i in range(m + 1)]


def min_cut_value(m: int, n: int) -> int:
    """The minimum A-B separator size: m+1 (the height), independent of n."""
    return m + 1
