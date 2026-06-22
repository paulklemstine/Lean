from itertools import combinations
from typing import Dict, List, Sequence, Tuple
import math

Point = Tuple[float, ...]

def dist(x: Point, y: Point) -> float:
    return math.sqrt(sum((a - b) ** 2 for a, b in zip(x, y)))

def _gf2_rank(mat: List[List[int]]) -> int:
    if not mat or not mat[0]:
        return 0
    rows = [row[:] for row in mat]
    n_rows, n_cols = len(rows), len(rows[0])
    rank = 0
    for col in range(n_cols):
        pivot = next((r for r in range(rank, n_rows) if rows[r][col]), None)
        if pivot is None:
            continue
        rows[rank], rows[pivot] = rows[pivot], rows[rank]
        for r in range(n_rows):
            if r != rank and rows[r][col]:
                rows[r] = [a ^ b for a, b in zip(rows[r], rows[rank])]
        rank += 1
    return rank

def betti_b1(points: Sequence[Point], r: float) -> int:
    """First Betti number (independent loops) of the VR complex at scale r,
    over GF(2): b1 = (E - rank d1) - rank d2."""
    n = len(points)
    edges = [e for e in combinations(range(n), 2)
             if dist(points[e[0]], points[e[1]]) <= r]
    tris = [t for t in combinations(range(n), 3)
            if all(dist(points[a], points[b]) <= r
                   for a, b in combinations(t, 2))]
    d1 = [[0] * len(edges) for _ in range(n)]
    for j, (a, b) in enumerate(edges):
        d1[a][j] ^= 1; d1[b][j] ^= 1
    eidx: Dict[Tuple[int, int], int] = {e: i for i, e in enumerate(edges)}
    d2 = [[0] * len(tris) for _ in range(len(edges))]
    for j, (a, b, c) in enumerate(tris):
        for e in ((a, b), (a, c), (b, c)):
            d2[eidx[e]][j] ^= 1
    return (len(edges) - _gf2_rank(d1)) - _gf2_rank(d2)
