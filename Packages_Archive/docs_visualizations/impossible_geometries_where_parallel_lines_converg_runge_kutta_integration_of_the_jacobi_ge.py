from __future__ import annotations
from typing import List, Tuple

def solve_jacobi(
    curvature: float,
    j0: float,
    jp0: float,
    t_max: float,
    n_steps: int,
) -> List[Tuple[float, float]]:
    """Solve the Jacobi (geodesic-deviation) equation J'' + K J = 0.

    Reduces to the first-order system (J, J')' = (J', -K J) and advances it with
    the classical RK4 method. Complexity: O(n_steps), four derivative evaluations
    per step. Returns sampled (t, J(t)) pairs.
    """
    dt = t_max / n_steps
    j, jp = j0, jp0
    samples: List[Tuple[float, float]] = [(0.0, j0)]
    t = 0.0
    for _ in range(n_steps):
        k1j, k1p = jp, -curvature * j
        k2j, k2p = jp + dt / 2 * k1p, -curvature * (j + dt / 2 * k1j)
        k3j, k3p = jp + dt / 2 * k2p, -curvature * (j + dt / 2 * k2j)
        k4j, k4p = jp + dt * k3p, -curvature * (j + dt * k3j)
        j += dt / 6 * (k1j + 2 * k2j + 2 * k3j + k4j)
        jp += dt / 6 * (k1p + 2 * k2p + 2 * k3p + k4p)
        t += dt
        samples.append((t, j))
    return samples
