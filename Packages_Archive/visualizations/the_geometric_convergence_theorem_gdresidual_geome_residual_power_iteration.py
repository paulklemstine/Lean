from typing import List, Sequence

Matrix = List[List[float]]
Vector = List[float]

def _matvec(K: Matrix, u: Sequence[float]) -> Vector:
    return [sum(K[i][k] * u[k] for k in range(len(u))) for i in range(len(K))]

def residual_power_iteration(K: Matrix, eta: float, u0: Vector, t: int) -> Vector:
    """Returns the GD residual after t steps: equals (I - eta K)^t u0."""
    u: Vector = list(u0)
    n = len(u)
    for _ in range(t):
        Ku = _matvec(K, u)
        u = [u[i] - eta * Ku[i] for i in range(n)]
    return u
