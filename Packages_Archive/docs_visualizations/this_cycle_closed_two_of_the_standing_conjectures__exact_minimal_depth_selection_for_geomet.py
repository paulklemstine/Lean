from __future__ import annotations
import math

def hodge_depth(rho: float, E: float, eps: float) -> int:
    """Exact minimal message-passing depth ceil(log_rho(eps/E))."""
    assert 0.0 < rho < 1.0 and E > 0.0 and eps > 0.0
    return max(0, math.ceil(math.log(eps / E) / math.log(rho)))
