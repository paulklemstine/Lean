from __future__ import annotations
import math
from typing import Tuple


def transfer_eigenvalues(beta: float) -> Tuple[float, float]:
    """Eigenvalues (lambda_+, lambda_-) = (2 cosh beta, 2 sinh beta)."""
    return (2.0 * math.cosh(beta), 2.0 * math.sinh(beta))


def partition_function_1d(beta: float, n_sites: int) -> float:
    """Exact periodic 1D partition function Z_N = tr T^N = lambda_+^N + lambda_-^N."""
    lam_plus, lam_minus = transfer_eigenvalues(beta)
    return lam_plus ** n_sites + lam_minus ** n_sites


def free_energy_density(beta: float, n_sites: int) -> float:
    """Numerically stable (1/N) ln Z_N = ln lambda_+ + (1/N) ln(1 + (lam_-/lam_+)^N)."""
    lam_plus, lam_minus = transfer_eigenvalues(beta)
    ratio = lam_minus / lam_plus
    return math.log(lam_plus) + math.log1p(ratio ** n_sites) / n_sites
