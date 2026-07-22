from __future__ import annotations
from typing import List

Matrix = List[List[float]]

def abs_row_sums(A: Matrix) -> List[float]:
    return [sum(abs(x) for x in row) for row in A]

def row_sum_bound(A: Matrix) -> float:
    return max(abs_row_sums(A))

def eigenvalue_within_bound(lam: float, A: Matrix) -> bool:
    return abs(lam) <= row_sum_bound(A) + 1e-9
