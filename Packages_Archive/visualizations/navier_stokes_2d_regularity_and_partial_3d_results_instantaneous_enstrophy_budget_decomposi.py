from typing import Callable, List
import numpy as np

Vector = np.ndarray


def inner(x: Vector, y: Vector) -> float:
    """Standard real inner product <x, y>."""
    return float(np.dot(x, y))


def enstrophy_budget(nu: float, A: np.ndarray,
                     B: Callable[[Vector, Vector], Vector],
                     v: Vector) -> dict:
    """
    Evaluate the two contributions to the instantaneous enstrophy rate
        Omega'(t) = -2 nu <A v, A v>  -  2 <B(v,v), A v>.

    Returns the viscous dissipation, the vortex-stretching production, their
    sum (the total rate), and the stretching residual (which is ~0 in 2D).
    """
    Av = A @ v
    viscous = -2.0 * nu * inner(Av, Av)
    stretching = -2.0 * inner(B(v, v), Av)
    return {
        "viscous_dissipation": viscous,
        "vortex_stretching": stretching,
        "total_rate": viscous + stretching,
        "stretching_residual": inner(B(v, v), Av),
    }
