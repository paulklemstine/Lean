from __future__ import annotations
from typing import List

Vector = List[float]
Matrix = List[List[float]]


def hodge_message_passing(
    B: Matrix, alpha: float, x0: Vector, depth: int
) -> Vector:
    """Run `depth` layers of Hodge message passing x -> x - alpha*(B^T B x).

    Each layer applies two sparse matrix-vector products (B then B^T),
    costing O(nnz(B)); total cost O(depth * nnz(B)).
    """
    def matvec(A: Matrix, v: Vector) -> Vector:
        return [sum(a * vi for a, vi in zip(row, v)) for row in A]

    Bt: Matrix = [list(col) for col in zip(*B)]
    x = list(x0)
    for _ in range(depth):
        bx = matvec(B, x)            # B x        (coboundary)
        lx = matvec(Bt, bx)          # B^T (B x)  = L x
        x = [xi - alpha * li for xi, li in zip(x, lx)]
    return x
