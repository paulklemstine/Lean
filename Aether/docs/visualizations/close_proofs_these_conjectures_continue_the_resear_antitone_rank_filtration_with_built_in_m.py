from fractions import Fraction
from typing import Callable, List

Matrix = List[List[Fraction]]


def rank(a: Matrix) -> int:
    """Exact rank of a matrix over Q via Gaussian elimination. O(d^3)."""
    m = [row[:] for row in a]
    rows = len(m)
    cols = len(m[0]) if m else 0
    r = 0
    for c in range(cols):
        pivot = next((i for i in range(r, rows) if m[i][c] != 0), None)
        if pivot is None:
            continue
        m[r], m[pivot] = m[pivot], m[r]
        inv = Fraction(1) / m[r][c]
        m[r] = [x * inv for x in m[r]]
        for i in range(rows):
            if i != r and m[i][c] != 0:
                factor = m[i][c]
                m[i] = [x - factor * y for x, y in zip(m[i], m[r])]
        r += 1
    return r


def rank_filtration(trans_endo_fn: Callable[[int, int, int], Matrix],
                    i: int, n_max: int, d: int) -> List[int]:
    """
    Compute the antitone rank filtration [rank Phi(i,0), ..., rank Phi(i,n_max)].
    By the rank-antitonicity theorem the output is non-increasing; this is
    asserted as a built-in correctness check. Complexity O(n_max * d^3).
    """
    ranks = [rank(trans_endo_fn(i, t, d)) for t in range(n_max + 1)]
    assert all(ranks[k + 1] <= ranks[k] for k in range(len(ranks) - 1)), \
        "rank filtration must be non-increasing"
    return ranks
