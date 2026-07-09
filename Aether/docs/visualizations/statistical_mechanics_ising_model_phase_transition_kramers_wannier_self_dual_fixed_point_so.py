from __future__ import annotations
import math


def kramers_wannier_dual(beta: float) -> float:
    """Return the Kramers-Wannier dual beta* solving sinh(2 beta) sinh(2 beta*) = 1."""
    return 0.5 * math.asinh(1.0 / math.sinh(2.0 * beta))


def self_dual_fixed_point(tol: float = 1e-15, max_iter: int = 200) -> float:
    """Bisection for the unique fixed point of D(beta) = beta on (0, inf).

    The self-dual condition collapses to sinh(2 beta) = 1, whose root is
    beta_c = (1/2) ln(1 + sqrt(2)).  We bracket the increasing function
    g(beta) = sinh(2 beta) - 1 between 0 and 1 and bisect.
    """
    def g(b: float) -> float:
        return math.sinh(2.0 * b) - 1.0

    lo, hi = 0.0, 1.0
    for _ in range(max_iter):
        mid = 0.5 * (lo + hi)
        if g(mid) > 0.0:
            hi = mid
        else:
            lo = mid
        if hi - lo < tol:
            break
    return 0.5 * (lo + hi)
