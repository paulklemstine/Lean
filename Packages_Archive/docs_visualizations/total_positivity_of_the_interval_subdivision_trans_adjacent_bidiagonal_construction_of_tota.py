from __future__ import annotations
from fractions import Fraction
from typing import List, Tuple

Matrix = List[List[Fraction]]
ColOp = Tuple[Fraction, int, int]  # (coefficient, source, target = source + 1)

def identity(n: int) -> Matrix:
    return [[Fraction(i == j) for j in range(n)] for i in range(n)]

def apply_valid_col_op(M: Matrix, op: ColOp) -> Matrix:
    alpha, src, tgt = op
    if alpha < 0 or tgt != src + 1:
        raise ValueError("operation is not a valid adjacent nonnegative column op")
    R = [row[:] for row in M]
    for i in range(len(M)):
        R[i][tgt] = M[i][tgt] + alpha * M[i][src]
    return R

def build_from_diagonal(diag: List[Fraction], ops: List[ColOp]) -> Matrix:
    if any(d < 0 for d in diag):
        raise ValueError("diagonal seed must be nonnegative")
    M: Matrix = [[Fraction(diag[i] if i == j else 0) for j in range(len(diag))]
                 for i in range(len(diag))]
    for op in ops:
        M = apply_valid_col_op(M, op)
    return M  # guaranteed totally nonnegative by the Preservation Lemma
