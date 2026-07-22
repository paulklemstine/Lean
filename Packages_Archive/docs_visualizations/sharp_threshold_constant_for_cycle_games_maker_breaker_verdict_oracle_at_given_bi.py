from __future__ import annotations
import math


def threshold_const(k: int) -> float:
    log_base: float = math.log(k - 1.0) + (k - 2) * math.log(2.0 * (k - 1.0) / k)
    return math.exp(log_base / (k - 1.0))


def game_verdict(k: int, n: float, q: float, eps: float = 1e-3) -> str:
    """Return 'Maker', 'Breaker', or 'window' for bias q at board size n."""
    q_star: float = threshold_const(k) * n ** ((k - 2.0) / (k - 1.0))
    if q < (1.0 - eps) * q_star:
        return "Maker"
    if q > (1.0 + eps) * q_star:
        return "Breaker"
    return "window"
