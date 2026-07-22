from __future__ import annotations
import math
from typing import Dict, Sequence


def expect(p: Sequence[float], f: Sequence[float]) -> float:
    """E_p[f] = sum_omega p(omega) f(omega)."""
    return sum(pi * fi for pi, fi in zip(p, f))


def landauer_work_decomposition(p: Sequence[float], W: Sequence[float],
                                alpha: float) -> Dict[str, float]:
    """Decompose the mean erasure work via the finite Jarzynski equality.

    Returns the reversible free-energy cost Delta_F recovered from
    E[exp(-alpha W)] = exp(-alpha Delta_F), the mean work E[W], the Jarzynski
    fluctuation factor E[exp(-alpha (W - E[W]))], and the nonnegative correction
    alpha^{-1} ln(fluctuation factor). By construction E[W] = Delta_F + correction.
    """
    mean_W = expect(p, W)
    z = expect(p, [math.exp(-alpha * Wi) for Wi in W])
    delta_F = -math.log(z) / alpha
    fluct = expect(p, [math.exp(-alpha * (Wi - mean_W)) for Wi in W])
    correction = math.log(fluct) / alpha
    return {"delta_F": delta_F, "mean_W": mean_W,
            "fluctuation_factor": fluct, "correction": correction}
