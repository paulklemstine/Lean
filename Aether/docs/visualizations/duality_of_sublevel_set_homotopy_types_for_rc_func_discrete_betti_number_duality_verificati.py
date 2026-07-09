"""Algorithm: Discrete Betti-Number Duality Verification.

Builds a finite grid model of two sublevel sets {f <= c} and {f_dual <= c},
computes their 0-th Betti numbers (number of 4-connected components) by a
union-find sweep, and asserts equality -- a computational witness of the
homology isomorphism H_*({f<=c}) = H_*({f_dual<=c}).
"""

from __future__ import annotations

from typing import Callable, Dict, List, Tuple

Point = Tuple[float, float]


def sublevel_grid(level_fn: Callable[[Point], float],
                  n: int, extent: float, c: float,
                  tol: float = 1e-9) -> Tuple[List[Tuple[int, int]], float]:
    """Integer-indexed grid points inside {level_fn <= c}; returns (cells, step)."""
    step: float = extent / n
    cells: List[Tuple[int, int]] = []
    for i in range(-n, n + 1):
        for j in range(-n, n + 1):
            point: Point = (i * step, j * step)
            if abs(point[0]) + abs(point[1]) <= 0.0:  # skip origin (q = 0)
                continue
            if level_fn(point) <= c + tol:
                cells.append((i, j))
    return cells, step


def betti0(cells: List[Tuple[int, int]]) -> int:
    """0-th Betti number = count of 4-connected components via union-find."""
    idx: Dict[Tuple[int, int], int] = {cell: k for k, cell in enumerate(cells)}
    parent: List[int] = list(range(len(cells)))

    def find(a: int) -> int:
        while parent[a] != a:
            parent[a] = parent[parent[a]]
            a = parent[a]
        return a

    def union(a: int, b: int) -> None:
        ra, rb = find(a), find(b)
        if ra != rb:
            parent[ra] = rb

    for (gx, gy), k in idx.items():
        for dgx, dgy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            nbr = (gx + dgx, gy + dgy)
            if nbr in idx:
                union(k, idx[nbr])
    return len({find(k) for k in range(len(cells))})


def duality_betti0_equal(f: Callable[[Point], float],
                         f_dual: Callable[[Point], float],
                         n: int, extent: float, c: float) -> Tuple[int, int, bool]:
    """Return (b0 of primal, b0 of dual, equal?)."""
    cells_p, _ = sublevel_grid(f, n, extent, c)
    cells_d, _ = sublevel_grid(f_dual, n, extent, c)
    bp, bd = betti0(cells_p), betti0(cells_d)
    return bp, bd, bp == bd
