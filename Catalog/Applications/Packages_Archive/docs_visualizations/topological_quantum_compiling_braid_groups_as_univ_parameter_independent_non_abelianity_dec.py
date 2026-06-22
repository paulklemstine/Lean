from __future__ import annotations
from typing import List, TypeVar
from fractions import Fraction

Number = TypeVar("Number", Fraction, complex)
Matrix = List[List[Number]]


def _mul(A: Matrix, B: Matrix) -> Matrix:
    n, m, p = len(A), len(B), len(B[0])
    zero = A[0][0] - A[0][0]
    out: Matrix = [[zero for _ in range(p)] for _ in range(n)]
    for i in range(n):
        for k in range(m):
            for j in range(p):
                out[i][j] += A[i][k] * B[k][j]
    return out


def jones_operators_commute(X: Matrix, Y: Matrix, tol: float = 1e-9) -> bool:
    """Decide whether jonesOp(u,X) and jonesOp(u,Y) commute, for ANY unit u.

    By the non-abelianity equivalence (Theorem 3.3) the weight u is irrelevant:
    the gates commute iff the generators commute, i.e. iff [X,Y] = 0. We thus
    never assemble the operators at all -- we test the generators directly.
    Complexity O(d^3); independent of u.
    """
    n = len(X)
    XY = _mul(X, Y)
    YX = _mul(Y, X)
    return all(abs(complex(XY[i][j] - YX[i][j])) <= tol
               for i in range(n) for j in range(n))
