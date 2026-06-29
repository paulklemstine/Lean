from __future__ import annotations
import math
from typing import Sequence, Tuple


def kl_sandwich(p: Sequence[float], q: Sequence[float]) -> Tuple[float, float, float]:
    """Return (2*TV^2, KL, chi^2) and assert the sandwich chain.

    Requires p, q strictly positive and each summing to 1.
    """
    assert all(pi > 0 for pi in p) and all(qi > 0 for qi in q)
    assert abs(sum(p) - 1.0) < 1e-9 and abs(sum(q) - 1.0) < 1e-9
    kl = sum(pi * math.log(pi / qi) for pi, qi in zip(p, q))
    chi = sum((pi - qi) ** 2 / qi for pi, qi in zip(p, q))
    fisher = sum((pi - qi) * (pi - qi) / qi for pi, qi in zip(p, q))
    tv_floor = 0.5 * sum(abs(pi - qi) for pi, qi in zip(p, q)) ** 2
    assert abs(chi - fisher) < 1e-9      # chiSquared_eq_fisher
    assert kl >= -1e-12                  # Gibbs
    assert kl <= chi + 1e-9              # bridge
    assert tv_floor <= kl + 1e-9         # Pinsker (conjecture)
    return tv_floor, kl, chi
