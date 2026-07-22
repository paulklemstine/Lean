from __future__ import annotations
from fractions import Fraction
from itertools import combinations
from typing import List, Sequence

Matrix = List[List[Fraction]]

def determinant(mat: Matrix) -> Fraction:
    n = len(mat); a = [row[:] for row in mat]; det = Fraction(1)
    for col in range(n):
        pivot = next((r for r in range(col, n) if a[r][col] != 0), None)
        if pivot is None:
            return Fraction(0)
        if pivot != col:
            a[col], a[pivot] = a[pivot], a[col]; det = -det
        det *= a[col][col]
        for r in range(col + 1, n):
            factor = a[r][col] / a[col][col]
            for c in range(col, n):
                a[r][c] -= factor * a[col][c]
    return det

def is_totally_nonnegative(rows: Sequence[Sequence[float]]) -> bool:
    M: Matrix = [[Fraction(x) for x in row] for row in rows]
    m, n = len(M), len(M[0])
    for k in range(1, min(m, n) + 1):
        for rs in combinations(range(m), k):
            for cs in combinations(range(n), k):
                sub = [[M[r][c] for c in cs] for r in rs]
                if determinant(sub) < 0:
                    return False
    return True
