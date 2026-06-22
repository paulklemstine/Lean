from __future__ import annotations
import math
from typing import List, Tuple

Vector = List[float]
Matrix = List[List[float]]


def spectral_depth_threshold(
    mu: float, lam: float, init_energy: float, eps: float,
    alpha: float | None = None,
) -> Tuple[int, float, float]:
    """Compute (K, alpha, rho): the finite depth K guaranteeing residual <= eps.

    Uses the optimal admissible step alpha = 1/lam when none is given, giving
    contraction rho = 1 - alpha*mu*(2 - alpha*lam). Returns the smallest K with
    rho^K * init_energy <= eps (Theorem: spectral_depth_threshold).
    """
    if alpha is None:
        alpha = 1.0 / lam
    assert 0.0 <= alpha and alpha * lam <= 2.0, "step size must be admissible"
    rho = 1.0 - alpha * mu * (2.0 - alpha * lam)
    assert 0.0 <= rho < 1.0, "need a strictly contractive factor"
    if init_energy <= eps:
        return 0, alpha, rho
    K = math.ceil(math.log(eps / init_energy) / math.log(rho))
    return K, alpha, rho
