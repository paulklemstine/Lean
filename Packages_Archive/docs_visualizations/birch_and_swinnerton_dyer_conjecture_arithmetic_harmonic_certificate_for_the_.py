from __future__ import annotations
from typing import List


def turan_caro_wei_bound(n: int, m: int) -> float:
    """Guaranteed independence-number lower bound  n^2 / (2m + n)."""
    return n ** 2 / (2 * m + n)


def caro_wei_weight(degrees: List[int]) -> float:
    """
    Caro–Wei weighted bound  sum_v 1/(deg v + 1), the sharper guarantee that
    dominates n^2/(2m+n) via the arithmetic–harmonic mean inequality.
    """
    return sum(1.0 / (d + 1) for d in degrees)


def amhm_certificate(degrees: List[int]) -> bool:
    """
    Verify the chain  n^2/(2m+n) <= sum_v 1/(deg v + 1)  using the
    arithmetic–harmonic mean inequality and the handshake identity
    sum_v deg v = 2m.
    """
    n = len(degrees)
    m = sum(degrees) // 2
    return turan_caro_wei_bound(n, m) <= caro_wei_weight(degrees) + 1e-9
