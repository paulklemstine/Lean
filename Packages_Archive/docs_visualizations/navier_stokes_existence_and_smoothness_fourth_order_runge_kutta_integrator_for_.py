import math
from typing import Callable, List, Sequence, Tuple

Vec = List[float]


def inner(u: Sequence[float], v: Sequence[float]) -> float:
    return sum(a * b for a, b in zip(u, v))


def rhs(u: Sequence[float], nu: float) -> Vec:
    """u' = -nu A u - B(u,u): diagonal A = diag((i+1)^2), B(u,u) = u x (diag(1,2,3) u)."""
    au = [nu * ((i + 1) ** 2) * ui for i, ui in enumerate(u)]
    m = (1.0 * u[0], 2.0 * u[1], 3.0 * u[2])
    bu = [u[1] * m[2] - u[2] * m[1], u[2] * m[0] - u[0] * m[2], u[0] * m[1] - u[1] * m[0]]
    return [-a - b for a, b in zip(au, bu)]


def rk4_energy_trace(u0: Vec, nu: float, dt: float, steps: int) -> List[Tuple[float, float]]:
    """Integrate with RK4 and return (t, energy ||u||^2); energy is nonincreasing."""
    def add(a: Sequence[float], b: Sequence[float], s: float) -> Vec:
        return [x + s * y for x, y in zip(a, b)]
    u = list(u0)
    trace = [(0.0, inner(u, u))]
    for n in range(1, steps + 1):
        k1 = rhs(u, nu); k2 = rhs(add(u, k1, dt / 2), nu)
        k3 = rhs(add(u, k2, dt / 2), nu); k4 = rhs(add(u, k3, dt), nu)
        u = [ui + (dt / 6) * (a + 2 * b + 2 * c + d)
             for ui, a, b, c, d in zip(u, k1, k2, k3, k4)]
        trace.append((n * dt, inner(u, u)))
    return trace
