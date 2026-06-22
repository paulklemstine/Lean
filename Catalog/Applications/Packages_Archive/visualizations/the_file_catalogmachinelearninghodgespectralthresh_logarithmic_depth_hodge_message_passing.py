from __future__ import annotations
import math
from typing import List

Vector = List[float]
Matrix = List[List[float]]

def dot(x: Vector, y: Vector) -> float:
    return sum(a * b for a, b in zip(x, y))

def matvec(A: Matrix, x: Vector) -> Vector:
    return [dot(row, x) for row in A]

def mp_step(L: Matrix, alpha: float, x: Vector) -> Vector:
    """One layer x -> x - alpha (L x)."""
    Lx = matvec(L, x)
    return [xi - alpha * lxi for xi, lxi in zip(x, Lx)]

def hodge_depth(rho: float, e0: float, eps: float) -> int:
    """N(eps) = ceil(log_rho(eps / e0)), the explicit logarithmic depth witness."""
    if e0 <= 0.0:
        return 0
    return max(0, math.ceil(math.log(eps / e0) / math.log(rho)))

def hodge_message_pass(L: Matrix, alpha: float, rho: float,
                       x: Vector, eps: float) -> Vector:
    """Apply exactly N(eps) message-passing layers; residual energy <= eps,
    harmonic component preserved exactly."""
    e0 = dot(x, x)
    n = hodge_depth(rho, e0, eps)
    for _ in range(n):
        x = mp_step(L, alpha, x)
    return x
