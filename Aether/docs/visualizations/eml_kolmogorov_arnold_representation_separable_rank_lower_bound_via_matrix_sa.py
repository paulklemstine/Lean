"""Separable-rank lower bound via matrix sampling (Theorem `sample_rank_le`,
Corollary `sepRankLE_ge_of_det_ne_zero`)."""
from __future__ import annotations
from fractions import Fraction
from typing import Callable, List, Optional, Sequence

Target = Callable[[Fraction, Fraction], Fraction]


def _det(matrix: List[List[Fraction]]) -> Fraction:
    n = len(matrix)
    a = [row[:] for row in matrix]
    det = Fraction(1)
    for c in range(n):
        piv = next((r for r in range(c, n) if a[r][c] != 0), None)
        if piv is None:
            return Fraction(0)
        if piv != c:
            a[c], a[piv] = a[piv], a[c]
            det = -det
        det *= a[c][c]
        for r in range(c + 1, n):
            f = a[r][c] / a[c][c]
            for k in range(c, n):
                a[r][k] -= f * a[c][k]
    return det


def separable_rank_lower_bound(
    f: Target, xs: Sequence[Fraction], ys: Sequence[Fraction]
) -> Optional[int]:
    """Return m (a certified lower bound on separable rank) if the m x m
    evaluation matrix M[i][j] = f(xs[i], ys[j]) is invertible, else None.

    Correctness: by the sampling theorem rank(M) <= sep_rank(f); if det(M) != 0
    then rank(M) = m, hence sep_rank(f) >= m. Complexity O(m^3)."""
    m = len(xs)
    assert len(ys) == m
    M = [[f(x, y) for y in ys] for x in xs]
    return m if _det(M) != 0 else None
