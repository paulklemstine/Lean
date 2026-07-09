from typing import List


def true_degree(h: List[int]) -> int:
    """Degree of an h*-polynomial, ignoring trailing zeros (0 for the zero poly)."""
    s = len(h) - 1
    while s > 0 and h[s] == 0:
        s -= 1
    return s


def is_gorenstein(h: List[int]) -> bool:
    """Decide whether the h*-vector ``h`` describes a Gorenstein polytope.

    Stanley--Hibi criterion: constant term 1, all coefficients nonnegative, and the
    coefficient vector is palindromic up to the true degree.
    """
    if not h or h[0] != 1:
        return False
    if any(c < 0 for c in h):
        return False
    s = true_degree(h)
    return all(h[i] == h[s - i] for i in range(s + 1))
