from __future__ import annotations
import math
from typing import Callable, Dict, Hashable

def expect(p: Dict[Hashable, float], f: Callable[[Hashable], float]) -> float:
    """Expectation E_p[f] = sum_omega p(omega) f(omega)."""
    return sum(prob * f(omega) for omega, prob in p.items())

def jarzynski_decomposition(
    p: Dict[Hashable, float],
    w: Callable[[Hashable], float],
    alpha: float,
) -> Dict[str, float]:
    """Decompose the mean work via the finite Jarzynski equality.

    Returns the implied free-energy difference DeltaF = -alpha^{-1} ln E[exp(-alpha W)],
    the mean work E[W], the nonnegative fluctuation correction
    alpha^{-1} ln E[exp(-alpha (W - E[W]))], and a check that
    E[W] = DeltaF + correction (the exact finite-size Landauer identity).
    """
    lhs = expect(p, lambda o: math.exp(-alpha * w(o)))
    delta_f = -math.log(lhs) / alpha
    mean_w = expect(p, w)
    factor = expect(p, lambda o: math.exp(-alpha * (w(o) - mean_w)))
    correction = math.log(factor) / alpha
    return {
        "delta_f": delta_f,
        "mean_work": mean_w,
        "correction": correction,
        "identity_residual": mean_w - (delta_f + correction),
        "second_law_holds": delta_f <= mean_w + 1e-15,
    }
