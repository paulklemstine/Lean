"""
Numerical demonstrations of the conservation laws of the planar Kepler problem.

This script verifies, on actual integrated trajectories, the three nested
conservation laws proved formally in the accompanying paper:

  1. Angular momentum   L_z = x*vy - y*vx          (any central force)
  2. Energy             E   = 0.5*(vx^2+vy^2) - k/r (inverse-square law)
  3. Laplace-Runge-Lenz A   = (L_z*vy - k*x/r,      (inverse-square law only)
                               -L_z*vx - k*y/r)

It also demonstrates the "fingerprint" result: the LRL vector is conserved only
for the inverse-square force (power p = 2); for forces ~ r^{-p} with p != 2 the
LRL vector drifts, growing with |p - 2|.

All functions are self-contained and use only the Python standard library.
"""

from __future__ import annotations

import math
from typing import Callable, List, Tuple

State = Tuple[float, float, float, float]  # (x, y, vx, vy)


def angular_momentum(s: State) -> float:
    """L_z = x*vy - y*vx (conserved for any central force)."""
    x, y, vx, vy = s
    return x * vy - y * vx


def energy(s: State, k: float) -> float:
    """E = 0.5*(vx^2 + vy^2) - k/r for the inverse-square (Kepler) potential."""
    x, y, vx, vy = s
    r = math.hypot(x, y)
    return 0.5 * (vx * vx + vy * vy) - k / r


def lrl_vector(s: State, k: float) -> Tuple[float, float]:
    """Laplace-Runge-Lenz vector A = (L_z*vy - k*x/r, -L_z*vx - k*y/r)."""
    x, y, vx, vy = s
    r = math.hypot(x, y)
    lz = angular_momentum(s)
    ax = lz * vy - k * x / r
    ay = -lz * vx - k * y / r
    return ax, ay


def acceleration(s: State, k: float, p: float = 2.0) -> Tuple[float, float]:
    """Central force ~ r^{-p}: (ax, ay) = -k * (x, y) / r^{p+1}.

    p = 2 recovers Newtonian gravity (inverse-square). The acceleration is
    radial for every p, so angular momentum is conserved regardless of p.
    """
    x, y, _vx, _vy = s
    r = math.hypot(x, y)
    factor = -k / (r ** (p + 1.0))
    return factor * x, factor * y


def velocity_verlet(
    s0: State, k: float, dt: float, steps: int, p: float = 2.0
) -> List[State]:
    """Symplectic velocity-Verlet integration of the central-force problem.

    Returns the full trajectory (length steps + 1). Velocity-Verlet is a
    symplectic integrator, so it preserves the conserved quantities with no
    secular drift.
    """
    x, y, vx, vy = s0
    traj: List[State] = [s0]
    ax, ay = acceleration((x, y, vx, vy), k, p)
    for _ in range(steps):
        # half-kick, drift, recompute force, half-kick
        vx_half = vx + 0.5 * dt * ax
        vy_half = vy + 0.5 * dt * ay
        x += dt * vx_half
        y += dt * vy_half
        ax, ay = acceleration((x, y, vx, vy), k, p)
        vx = vx_half + 0.5 * dt * ax
        vy = vy_half + 0.5 * dt * ay
        traj.append((x, y, vx, vy))
    return traj


def max_drift(values: List[float]) -> float:
    """Maximum absolute deviation of a list from its first entry."""
    v0 = values[0]
    return max(abs(v - v0) for v in values)


def elliptical_initial_condition(k: float, a: float, e: float) -> State:
    """Initial state at pericenter of an ellipse with semi-major axis a and
    eccentricity e under Newtonian gravity with coupling k.

    At pericenter r = a*(1 - e), the velocity is purely tangential with speed
    given by the vis-viva equation v^2 = k*(2/r - 1/a).
    """
    r_peri = a * (1.0 - e)
    v_peri = math.sqrt(k * (2.0 / r_peri - 1.0 / a))
    return (r_peri, 0.0, 0.0, v_peri)


def demo_kepler_conservation() -> None:
    """Demo 1: verify L_z, E, and the LRL vector are conserved on a full
    Newtonian (inverse-square) elliptical orbit."""
    print("=" * 70)
    print("DEMO 1: Conservation laws on a Newtonian elliptical orbit (p = 2)")
    print("=" * 70)
    k = 1.0
    a, e = 1.0, 0.6
    s0 = elliptical_initial_condition(k, a, e)
    dt = 1e-4
    steps = 200_000  # several orbital periods
    traj = velocity_verlet(s0, k, dt, steps, p=2.0)

    lz = [angular_momentum(s) for s in traj]
    en = [energy(s, k) for s in traj]
    ax = [lrl_vector(s, k)[0] for s in traj]
    ay = [lrl_vector(s, k)[1] for s in traj]

    print(f"  initial state (pericenter): x={s0[0]:.4f}, vy={s0[3]:.4f}")
    print(f"  semi-major axis a={a}, eccentricity e={e}")
    print(f"  L_z   initial = {lz[0]:+.6f}   max drift = {max_drift(lz):.2e}")
    print(f"  E     initial = {en[0]:+.6f}   max drift = {max_drift(en):.2e}")
    print(f"  A_x   initial = {ax[0]:+.6f}   max drift = {max_drift(ax):.2e}")
    print(f"  A_y   initial = {ay[0]:+.6f}   max drift = {max_drift(ay):.2e}")
    amag = math.hypot(ax[0], ay[0])
    print(f"  |A| = {amag:.6f}  vs predicted k*e = {k * e:.6f}")
    print(f"  A direction (toward pericenter): ({ax[0] / amag:+.4f}, "
          f"{ay[0] / amag:+.4f})  expected (+1, 0)")
    print()


def demo_force_law_discriminator() -> None:
    """Demo 2: the LRL fingerprint. Angular momentum is conserved for every
    power-law central force, but the LRL vector is conserved only at p = 2."""
    print("=" * 70)
    print("DEMO 2: LRL fingerprint -- conserved only for inverse-square (p=2)")
    print("=" * 70)
    k = 1.0
    a, e = 1.0, 0.6
    s0 = elliptical_initial_condition(k, a, e)
    dt = 1e-4
    steps = 60_000
    print(f"  {'power p':>8} | {'L_z drift':>12} | {'LRL drift':>12}")
    print("  " + "-" * 40)
    for p in (1.6, 1.8, 1.9, 2.0, 2.1, 2.2, 2.4):
        traj = velocity_verlet(s0, k, dt, steps, p=p)
        lz = [angular_momentum(s) for s in traj]
        # Use the p=2 LRL definition as the diagnostic observable.
        ax = [lrl_vector(s, k)[0] for s in traj]
        ay = [lrl_vector(s, k)[1] for s in traj]
        lrl_drift = max(max_drift(ax), max_drift(ay))
        tag = "  <-- inverse-square" if abs(p - 2.0) < 1e-9 else ""
        print(f"  {p:>8.2f} | {max_drift(lz):>12.2e} | "
              f"{lrl_drift:>12.2e}{tag}")
    print()
    print("  Angular momentum drift stays at integrator noise for ALL p")
    print("  (every power-law force is central). LRL drift is minimized at")
    print("  p = 2 and grows with |p - 2|: the algebraic fingerprint of the")
    print("  inverse-square law.")
    print()


def demo_angular_momentum_robustness() -> None:
    """Demo 3: angular momentum is the most robust law -- conserved even for a
    time-varying central force a(t) with no fixed potential."""
    print("=" * 70)
    print("DEMO 3: Angular momentum robustness under a time-varying central force")
    print("=" * 70)
    # Custom integrator with an explicitly time-dependent radial strength a(t).
    k = 1.0
    s0 = (1.0, 0.0, 0.1, 1.0)
    dt = 1e-4
    steps = 100_000
    x, y, vx, vy = s0
    lz_vals: List[float] = [angular_momentum(s0)]
    t = 0.0
    for _ in range(steps):
        # radial strength varies in time AND with radius -- still central
        r = math.hypot(x, y)
        a_scalar = -(1.0 + 0.5 * math.sin(3.0 * t)) * k / r ** 3
        ax, ay = a_scalar * x, a_scalar * y
        vx_h = vx + 0.5 * dt * ax
        vy_h = vy + 0.5 * dt * ay
        x += dt * vx_h
        y += dt * vy_h
        r = math.hypot(x, y)
        a_scalar = -(1.0 + 0.5 * math.sin(3.0 * (t + dt))) * k / r ** 3
        ax, ay = a_scalar * x, a_scalar * y
        vx = vx_h + 0.5 * dt * ax
        vy = vy_h + 0.5 * dt * ay
        t += dt
        lz_vals.append(angular_momentum((x, y, vx, vy)))
    print("  Force = a(t) * (x, y) with a(t) = -(1 + 0.5 sin 3t) k / r^3")
    print("  (time-varying strength -> energy NOT conserved, but force central)")
    print(f"  L_z initial = {lz_vals[0]:+.6f}   max drift = "
          f"{max_drift(lz_vals):.2e}")
    print("  Angular momentum survives even when energy does not: the rotational")
    print("  symmetry charge requires only centrality.")
    print()


def main() -> None:
    demo_kepler_conservation()
    demo_force_law_discriminator()
    demo_angular_momentum_robustness()


if __name__ == "__main__":
    main()
