from __future__ import annotations
import math
from typing import Callable, List
Vector = List[float]; Matrix = List[List[float]]

def dot(a: Vector, b: Vector) -> float:
    return sum(x * y for x, y in zip(a, b))

def matvec(M: Matrix, v: Vector) -> Vector:
    return [dot(row, v) for row in M]

def axpy(alpha: float, x: Vector, y: Vector) -> Vector:
    return [alpha * xi + yi for xi, yi in zip(x, y)]

def rk4_step(f: Callable[[Vector], Vector], u: Vector, dt: float) -> Vector:
    k1 = f(u)
    k2 = f(axpy(dt / 2, k1, u))
    k3 = f(axpy(dt / 2, k2, u))
    k4 = f(axpy(dt, k3, u))
    incr = [(a + 2*b + 2*c + d) / 6 for a, b, c, d in zip(k1, k2, k3, k4)]
    return axpy(dt, incr, u)

def verify_energy_decay(nu: float, A: Matrix,
                        B: Callable[[Vector, Vector], Vector],
                        u0: Vector, dt: float, N: int,
                        tol: float = 1e-9) -> bool:
    lam = min(A[i][i] for i in range(len(A)))
    f = lambda w: axpy(-nu, matvec(A, w), [-c for c in B(w, w)])
    u = list(u0); E0 = dot(u, u); E_prev = math.inf
    for k in range(1, N + 1):
        u = rk4_step(f, u, dt)
        E = dot(u, u); t = k * dt
        if not (E <= E_prev + tol):
            return False
        if not (E <= E0 * math.exp(-2 * nu * lam * t) + tol):
            return False
        E_prev = E
    return True
