from __future__ import annotations
from typing import Tuple


def guaranteed_lifetime_envelope(C: float, Z0: float, t: float) -> Tuple[float, float]:
    """Return (T_star, envelope(t)) for the 3D supercritical bound Z' <= C Z^3.

    T_star = 1 / (2 C Z0^2) is the guaranteed existence time; the envelope
    Z0^2 / (1 - 2 C Z0^2 t) bounds Z(t)^2 on [0, T_star). Raises ValueError
    if t is outside the certified interval. Complexity: O(1)."""
    if C <= 0.0 or Z0 <= 0.0:
        raise ValueError("require C > 0 and Z0 > 0")
    T_star: float = 1.0 / (2.0 * C * Z0 ** 2)
    if not (0.0 <= t < T_star):
        raise ValueError(f"t must lie in [0, T*={T_star}) for a finite envelope")
    envelope: float = Z0 ** 2 / (1.0 - 2.0 * C * Z0 ** 2 * t)
    return T_star, envelope


def blowup_rate_certificate(
    C: float, T_star: float, samples: list[tuple[float, float]]
) -> bool:
    """No-blow-up certificate from the lower rate Z(t)^2 >= 1/(2C(T*-t)).

    Given an enstrophy trace [(t, Z(t)), ...] and a candidate singular time
    T_star, return True if every sample satisfies the lower envelope (consistent
    with blow-up at T_star), and False if any sample with t < T_star violates it
    (which rigorously excludes a singularity at T_star). Complexity: O(n)."""
    for t, Z in samples:
        if t >= T_star:
            continue
        lower: float = 1.0 / (2.0 * C * (T_star - t))
        if Z ** 2 < lower:
            return False
    return True
