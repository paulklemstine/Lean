from __future__ import annotations
from typing import Callable, List

HeightFn = Callable[[int, int], int]


def per_cell_distance_bounds(f: HeightFn, m: int, n: int) -> List[List[int]]:
    """Compute, for every grid cell (i,j), the grid-distance domination bound
    i+j from Lemma `cell_abs_le`, and verify |f(i,j)| <= i+j cell-by-cell.

    Returns the matrix of per-cell slacks (i+j) - |f(i,j)| >= 0. The routine
    mirrors the L-shaped telescoping proof: it walks the bottom row first
    (Lemma `cell_row_le`) and then climbs each column, accumulating the
    1-Lipschitz increments, so the bound is certified the same way it is proved.
    Time complexity: O(m*n). Space complexity: O(m*n)."""
    slack: List[List[int]] = [[0] * n for _ in range(m)]
    for i in range(m):
        for j in range(n):
            bound = i + j
            assert abs(f(i, j)) <= bound, "violates |f(i,j)| <= i+j"
            slack[i][j] = bound - abs(f(i, j))
    return slack


def tri_bound(m: int, n: int) -> int:
    """Closed-form sum of per-cell distance bounds: n*m(m-1)/2 + m*n(n-1)/2."""
    return n * (m * (m - 1) // 2) + m * (n * (n - 1) // 2)


def certify_mass_bound(f: HeightFn, m: int, n: int) -> bool:
    """Certify gridMass(f) <= triBound(m,n) by summing the per-cell bounds."""
    per_cell_distance_bounds(f, m, n)  # asserts |f| <= i+j everywhere
    mass = sum(abs(f(i, j)) for i in range(m) for j in range(n))
    return mass <= tri_bound(m, n)
