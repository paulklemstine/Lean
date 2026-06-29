from fractions import Fraction
from itertools import product
from typing import Sequence

Matrix = Sequence[Sequence[Fraction]]


def is_dist_matrix(d: Matrix, n: int) -> bool:
    """Nonnegative, zero diagonal, symmetric."""
    for i in range(n):
        if d[i][i] != 0:
            return False
        for j in range(n):
            if d[i][j] < 0 or d[i][j] != d[j][i]:
                return False
    return True


def vr_interleaving_distance(d1: Matrix, d2: Matrix, n: int) -> Fraction:
    """Exact VR interleaving distance via edge-realization: O(n^2)."""
    assert is_dist_matrix(d1, n) and is_dist_matrix(d2, n)
    return max(abs(d1[x][y] - d2[x][y]) for x, y in product(range(n), repeat=2))
