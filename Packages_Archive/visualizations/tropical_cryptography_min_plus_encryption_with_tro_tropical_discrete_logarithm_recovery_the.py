from __future__ import annotations
import math
from typing import List

Matrix = List[List[float]]
Vector = List[float]

def trop_matvec(A: Matrix, v: Vector) -> Vector:
    return [min(A[i][k] + v[k] for k in range(len(v))) for i in range(len(A))]

def tdlp_recover_exponent(A: Matrix, B: Matrix, v: Vector, lam: float) -> float:
    """
    Recover the secret exponent m from public (A, B = A^{(x)m}) given an
    eigenpair (lam, v) of A with lam != 0, via eigenvalue additivity:
        lambda(A^{(x)m}) = m * lambda(A)   =>   m = residual(B, v) / lam.
    """
    if abs(lam) < 1e-12:
        raise ValueError("lambda = 0: boundary case carries no information")
    residual = trop_matvec(B, v)[0] - v[0]
    return residual / lam
