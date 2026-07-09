from __future__ import annotations
import math
from typing import List, Tuple

State = Tuple[float, float, float, float]


def acceleration(s: State, k: float, p: float) -> Tuple[float, float]:
    """Power-law central force (ax, ay) = -k (x, y) / r^{p+1}."""
    x, y, _, _ = s
    r = math.hypot(x, y)
    f = -k / r ** (p + 1.0)
    return f * x, f * y


def velocity_verlet(s0: State, k: float, dt: float, steps: int,
                    p: float) -> List[State]:
    """Symplectic velocity-Verlet integration of a power-law central force."""
    x, y, vx, vy = s0
    traj = [s0]
    ax, ay = acceleration((x, y, vx, vy), k, p)
    for _ in range(steps):
        vx += 0.5 * dt * ax; vy += 0.5 * dt * ay
        x += dt * vx; y += dt * vy
        ax, ay = acceleration((x, y, vx, vy), k, p)
        vx += 0.5 * dt * ax; vy += 0.5 * dt * ay
        traj.append((x, y, vx, vy))
    return traj


def lrl_drift(traj: List[State], k: float) -> float:
    """Maximum drift of the (p=2) LRL vector along a trajectory."""
    def lrl(s: State) -> Tuple[float, float]:
        x, y, vx, vy = s
        r = math.hypot(x, y)
        lz = x * vy - y * vx
        return lz * vy - k * x / r, -lz * vx - k * y / r
    a0 = lrl(traj[0])
    d = 0.0
    for s in traj:
        a = lrl(s)
        d = max(d, abs(a[0] - a0[0]), abs(a[1] - a0[1]))
    return d


def discriminate_force_law(s0: State, k: float, dt: float, steps: int,
                           powers: List[float]) -> List[Tuple[float, float]]:
    """For each power p, return (p, LRL drift). Drift is minimized at p = 2."""
    out = []
    for p in powers:
        traj = velocity_verlet(s0, k, dt, steps, p)
        out.append((p, lrl_drift(traj, k)))
    return out
