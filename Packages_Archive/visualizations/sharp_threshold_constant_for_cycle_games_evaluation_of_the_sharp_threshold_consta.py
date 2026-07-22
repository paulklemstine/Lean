from __future__ import annotations
import math


def threshold_const(k: int) -> float:
    """Return c_k = ((k-1)*(2(k-1)/k)^{k-2})^{1/(k-1)} for k >= 4."""
    if k < 4:
        raise ValueError("k must be at least 4")
    log_base: float = math.log(k - 1.0) + (k - 2) * math.log(2.0 * (k - 1.0) / k)
    return math.exp(log_base / (k - 1.0))
