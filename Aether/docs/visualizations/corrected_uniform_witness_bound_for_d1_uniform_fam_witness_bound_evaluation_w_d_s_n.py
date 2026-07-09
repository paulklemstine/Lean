from math import comb


def witness_bound(d: int, s: int, n: int) -> int:
    """W(d, s, n): the certified maximum family size."""
    if s == 0:
        return comb(n, d + 1)
    return comb(n, d) // s
