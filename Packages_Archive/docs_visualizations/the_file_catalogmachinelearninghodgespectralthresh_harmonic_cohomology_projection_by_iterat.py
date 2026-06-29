from __future__ import annotations
from typing import List

Vector = List[float]
Matrix = List[List[float]]

def dot(x: Vector, y: Vector) -> float:
    return sum(a * b for a, b in zip(x, y))

def matvec(A: Matrix, x: Vector) -> Vector:
    return [dot(row, x) for row in A]

def mp_step(L: Matrix, alpha: float, x: Vector) -> Vector:
    Lx = matvec(L, x)
    return [xi - alpha * lxi for xi, lxi in zip(x, Lx)]

def harmonic_projection(L: Matrix, alpha: float, x: Vector,
                        max_iter: int = 100000, tol: float = 1e-12) -> Vector:
    """Iterate mpStep to convergence; the limit is the orthogonal projection of
    x onto ker L (the harmonic / cohomology representative)."""
    prev = x
    for _ in range(max_iter):
        cur = mp_step(L, alpha, prev)
        if sum((a - b) ** 2 for a, b in zip(cur, prev)) < tol:
            return cur
        prev = cur
    return prev
