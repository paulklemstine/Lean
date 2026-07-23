from __future__ import annotations
from fractions import Fraction
from typing import TypeAlias
Scalar: TypeAlias = Fraction
Vector: TypeAlias = list[Scalar]
Matrix: TypeAlias = list[list[Scalar]]

def mul(a: Matrix, b: Matrix) -> Matrix:
    n=len(a)
    if n == 0 or any(len(r) != n for r in a+b): raise ValueError("square matrices required")
    return [[min(a[i][k]+b[k][j] for k in range(n)) for j in range(n)] for i in range(n)]

def act(a: Matrix, v: Vector) -> Vector:
    return [min(row[j]+v[j] for j in range(len(v))) for row in a]

def power(a: Matrix, k: int) -> Matrix:
    if k < 0: raise ValueError("k must be nonnegative")
    p=[r[:] for r in a]
    for _ in range(k): p=mul(a,p)
    return p

def eigenvalue(a: Matrix, v: Vector) -> Scalar:
    offsets=[x-y for x,y in zip(act(a,v),v)]
    if not offsets or len(set(offsets)) != 1: raise ValueError("not an eigenvector")
    return offsets[0]

def recover(lam: Scalar, mu: Scalar) -> int:
    if lam == 0: raise ValueError("zero eigenvalue")
    k=mu/lam-1
    if k.denominator != 1 or k < 0: raise ValueError("inconsistent observations")
    return k.numerator

if __name__ == "__main__": print(recover(Fraction(2),Fraction(14)))
