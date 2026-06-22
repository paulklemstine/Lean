from __future__ import annotations
import math
from typing import Sequence, List

def expect(p: Sequence[float], f: Sequence[float]) -> float:
    return sum(pi * fi for pi, fi in zip(p, f))

def landauer_erasure_certificate(
    p: Sequence[float], w_raw: Sequence[float], k: float, T: float
) -> dict:
    """
    Build a Jarzynski-consistent one-bit erasure process at temperature T and
    certify the Landauer bound kT ln 2 <= E[W].

    The raw work values w_raw are shifted by a constant so the Jarzynski
    equality holds exactly for dF = kT ln 2; the bound is then certified, and
    saturation (E[W] == dF) is detected iff the work is deterministic.
    """
    assert k > 0.0 and T > 0.0
    alpha = 1.0 / (k * T)
    dF = k * T * math.log(2)
    z = expect(p, [math.exp(-alpha * wi) for wi in w_raw])
    c = dF + math.log(z) / alpha
    w: List[float] = [wi + c for wi in w_raw]
    ew = expect(p, w)
    deterministic = max(w) - min(w) < 1e-15
    return {
        "free_energy": dF,
        "mean_work": ew,
        "surcharge": ew - dF,
        "bound_holds": ew >= dF - 1e-30,
        "saturated": abs(ew - dF) < 1e-30,
        "deterministic": deterministic,
    }
