from __future__ import annotations
from typing import Callable, List
Vector = List[float]; Matrix = List[List[float]]

def dot(a: Vector, b: Vector) -> float:
    return sum(x * y for x, y in zip(a, b))

def matvec(M: Matrix, v: Vector) -> Vector:
    return [dot(row, v) for row in M]

def axpy(alpha: float, x: Vector, y: Vector) -> Vector:
    return [alpha * xi + yi for xi, yi in zip(x, y)]

def rk4_step(f: Callable[[Vector], Vector], u: Vector, dt: float) -> Vector:
    k1 = f(u); k2 = f(axpy(dt/2, k1, u))
    k3 = f(axpy(dt/2, k2, u)); k4 = f(axpy(dt, k3, u))
    incr = [(a+2*b+2*c+d)/6 for a,b,c,d in zip(k1,k2,k3,k4)]
    return axpy(dt, incr, u)

def stretching_ratio(nu: float, A: Matrix,
                     B: Callable[[Vector, Vector], Vector], u: Vector) -> float:
    Au = matvec(A, u)
    den = nu * dot(Au, Au)
    return 0.0 if abs(den) < 1e-15 else -dot(B(u, u), Au) / den

def monitor_conditional_regularity(nu: float, A: Matrix,
                                   B: Callable[[Vector, Vector], Vector],
                                   u0: Vector, dt: float, N: int) -> bool:
    f = lambda w: axpy(-nu, matvec(A, w), [-c for c in B(w, w)])
    u = list(u0); controlled = True
    for _ in range(N):
        controlled = controlled and (stretching_ratio(nu, A, B, u) <= 1.0 + 1e-9)
        u = rk4_step(f, u, dt)
    return controlled
