from __future__ import annotations
import math
from typing import Sequence, Tuple

def expect(p: Sequence[float], f: Sequence[float]) -> float:
    return sum(pi * fi for pi, fi in zip(p, f))

def jarzynski_free_energy_and_dissipation(
    p: Sequence[float], w: Sequence[float], alpha: float
) -> Tuple[float, float, float]:
    """
    Return (dF, mean_work, correction) for inverse temperature alpha > 0.

    dF         = -alpha^{-1} log E[exp(-alpha W)]        (Jarzynski equality)
    mean_work  = E[W]
    correction = alpha^{-1} log E[exp(-alpha (W - E[W]))]  >= 0
    By jarzynski_second_law: mean_work - dF == correction >= 0.
    """
    assert alpha > 0.0
    z = expect(p, [math.exp(-alpha * wi) for wi in w])
    dF = -math.log(z) / alpha
    ew = expect(p, w)
    zc = expect(p, [math.exp(-alpha * (wi - ew)) for wi in w])
    correction = math.log(zc) / alpha
    return dF, ew, correction
