from __future__ import annotations
import math


def dual_beta(beta: float) -> float:
    """Kramers-Wannier dual inverse temperature.

    Solves sinh(2 beta) * sinh(2 beta*) = 1 for beta*, giving
    beta* = (1/2) arcsinh(1 / sinh(2 beta)).  The map is a strictly
    order-reversing involution of (0, inf); its unique fixed point is beta_c.
    Complexity: O(1) per evaluation.
    """
    return 0.5 * math.asinh(1.0 / math.sinh(2.0 * beta))


def is_fixed_point(beta: float, tol: float = 1e-12) -> bool:
    """Return True if beta is (numerically) self-dual."""
    return math.isclose(dual_beta(beta), beta, abs_tol=tol)
