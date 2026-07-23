from __future__ import annotations
import math
from typing import Tuple

Matrix = Tuple[float, float, float, float]   # (a, b, c, d) for [[a,b],[c,d]]
Vector = Tuple[float, float]


def unstretched_vector(M: Matrix) -> Vector:
    """
    Given a real 2x2 matrix M = [[a,b],[c,d]] with (det M)^2 = 1, return a nonzero
    vector v = (x, y) such that ||M v|| = ||v|| (Euclidean norm).

    Closed-form witness from the quadratic form
        Q(x,y) = A x^2 + 2 B x y + C y^2,
        A = a^2 + c^2 - 1,  B = a b + c d,  C = b^2 + d^2 - 1.
    The discriminant D = B^2 - A C = ||M||_F^2 - (det M)^2 - 1 is >= 0 when det^2 = 1.
    """
    a, b, c, d = M
    A = a * a + c * c - 1.0
    B = a * b + c * d
    C = b * b + d * d - 1.0
    if abs(A) < 1e-12:
        return (1.0, 0.0)                 # (1,0) already has unit image length
    D = B * B - A * C                      # guaranteed >= 0 for unimodular M
    s = math.sqrt(max(D, 0.0))
    x = (-B + s) / A
    return (x, 1.0)


def stretch_ratio(M: Matrix, v: Vector) -> float:
    a, b, c, d = M
    x, y = v
    return math.hypot(a * x + b * y, c * x + d * y) / math.hypot(x, y)
