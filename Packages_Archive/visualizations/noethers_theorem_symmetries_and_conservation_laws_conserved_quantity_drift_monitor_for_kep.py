from __future__ import annotations
import math
from typing import List, Tuple

State = Tuple[float, float, float, float]  # (x, y, vx, vy)


def conserved_quantities(s: State, k: float) -> Tuple[float, float, float, float]:
    """Return (L_z, E, A_x, A_y) for a unit-mass particle under the
    inverse-square Kepler potential with coupling k."""
    x, y, vx, vy = s
    r = math.hypot(x, y)
    lz = x * vy - y * vx
    e = 0.5 * (vx * vx + vy * vy) - k / r
    ax = lz * vy - k * x / r
    ay = -lz * vx - k * y / r
    return lz, e, ax, ay


def drift_monitor(traj: List[State], k: float) -> dict:
    """O(N) monitor: maximum deviation of each conserved quantity from its
    initial value along an integrated trajectory. The exact values are zero."""
    base = conserved_quantities(traj[0], k)
    names = ("L_z", "E", "A_x", "A_y")
    drift = {n: 0.0 for n in names}
    for s in traj:
        cur = conserved_quantities(s, k)
        for n, b, c in zip(names, base, cur):
            drift[n] = max(drift[n], abs(c - b))
    return drift
