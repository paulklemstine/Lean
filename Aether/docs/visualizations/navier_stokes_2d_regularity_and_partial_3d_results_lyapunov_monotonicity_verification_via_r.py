from typing import Callable, List, Tuple
import numpy as np

Vector = np.ndarray


def verify_lyapunov_monotonicity(
    nu: float, A: np.ndarray,
    B: Callable[[Vector, Vector], Vector],
    u0: Vector, t_final: float, n_steps: int,
    tol: float = 1e-7,
) -> Tuple[bool, bool]:
    """
    Integrate u' = -nu A u - B(u, u) with RK4 and check whether the energy
    E = <u, u> and the enstrophy Omega = <A u, u> are nonincreasing along the
    discrete trajectory. Returns (energy_monotone, enstrophy_monotone).

    In 2D (vortex-stretching cancellation) both should be True; in 3D with a
    strong nonlinearity the enstrophy flag may be False while energy stays True.
    """
    dt = t_final / n_steps
    u = u0.astype(float).copy()
    E_prev = float(np.dot(u, u))
    Om_prev = float(np.dot(A @ u, u))
    energy_ok, enstrophy_ok = True, True

    def f(x: Vector) -> Vector:
        return -nu * (A @ x) - B(x, x)

    for _ in range(n_steps):
        k1 = f(u)
        k2 = f(u + 0.5 * dt * k1)
        k3 = f(u + 0.5 * dt * k2)
        k4 = f(u + dt * k3)
        u = u + (dt / 6.0) * (k1 + 2 * k2 + 2 * k3 + k4)
        E = float(np.dot(u, u))
        Om = float(np.dot(A @ u, u))
        if E > E_prev + tol:
            energy_ok = False
        if Om > Om_prev + tol:
            enstrophy_ok = False
        E_prev, Om_prev = E, Om
    return energy_ok, enstrophy_ok
