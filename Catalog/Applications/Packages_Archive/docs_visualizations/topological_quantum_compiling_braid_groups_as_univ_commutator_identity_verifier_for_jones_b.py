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


def _sub(A: Matrix, B: Matrix) -> Matrix:
    return [[A[i][j] - B[i][j] for j in range(len(A[0]))] for i in range(len(A))]


def _smul(c: Number, A: Matrix) -> Matrix:
    return [[c * A[i][j] for j in range(len(A[0]))] for i in range(len(A))]


def _add(A: Matrix, B: Matrix) -> Matrix:
    return [[A[i][j] + B[i][j] for j in range(len(A[0]))] for i in range(len(A))]


def verify_commutator_identity(u: Number, X: Matrix, Y: Matrix, tol: float = 1e-9) -> bool:
    """Verify  [jonesOp(u,X), jonesOp(u,Y)] == u^{-2} [X,Y]  (Theorem 3.2).

    Builds J_X = u*I + (1/u)*X and J_Y likewise, then compares the operator
    commutator to the scaled generator commutator entrywise within tolerance.
    Complexity O(d^3) for d x d matrices (schoolbook multiplication).
    """
    n = len(X)
    one = u / u
    I = [[one if i == j else one - one for j in range(n)] for i in range(n)]
    JX = _add(_smul(u, I), _smul(one / u, X))
    JY = _add(_smul(u, I), _smul(one / u, Y))
    lhs = _sub(_mul(JX, JY), _mul(JY, JX))
    rhs = _smul((one / u) * (one / u), _sub(_mul(X, Y), _mul(Y, X)))
    return all(abs(complex(_sub(lhs, rhs)[i][j])) <= tol
               for i in range(n) for j in range(n))
