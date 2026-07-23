from __future__ import annotations
import math
from typing import List

def layer_schedule(rho: float, tolerances: List[float]) -> List[int]:
    """Per-stage incremental layer budgets; independent of signal energy."""
    assert 0.0 < rho < 1.0
    assert all(a > b > 0.0 for a, b in zip(tolerances, tolerances[1:]))
    out: List[int] = []
    for prev, cur in zip(tolerances, tolerances[1:]):
        inc = math.log(cur / prev) / math.log(rho)   # log_rho(cur/prev)
        out.append(max(0, math.ceil(inc)))
    return out
