from __future__ import annotations
import math


def critical_depth(mu: float, t: float, eps: float) -> int:
    """Smallest depth L_c with (1 - t*mu)^L <= eps for all L >= L_c.

    Realizes the `depth_threshold` theorem:
        L_c = ceil( log(eps) / log(1 - t*mu) ).
    Requires the normalized-step regime 0 < t*mu < 1 so that the per-layer
    gap factor r = 1 - t*mu lies strictly in (0, 1).
    """
    r: float = 1.0 - t * mu
    if not (0.0 < r < 1.0):
        raise ValueError("need 0 < t*mu < 1 (normalized step)")
    if eps <= 0.0:
        raise ValueError("tolerance eps must be positive")
    return max(0, math.ceil(math.log(eps) / math.log(r)))
