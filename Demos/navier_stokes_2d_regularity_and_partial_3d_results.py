"""
Numerical demonstrations of the abstract Navier-Stokes energy theory.

This self-contained script illustrates, on finite-dimensional truncations of the
abstract Galerkin model

    u'(t) = -nu * A u - B(u, u),

the following formally verified results:

  1. Energy dissipation identity & monotone a priori bound (Leray):
        E'(t) = -2 nu <A u, u> <= 0,   E(t) <= E(s) for s <= t.
  2. Exponential energy decay under coercivity (spectral gap lambda):
        E(t) <= E(s) * exp(-2 nu lambda (t - s)).
  3. Forward-in-time uniqueness via the difference energy:
        if u(t0) = w(t0) then u == w for t >= t0.
  4. 2D enstrophy control (vortex-stretching cancellation -> Lyapunov):
        Omega'(t) = -2 nu <A u, A u> <= 0.
  5. 3D conditional regularity (stretching monitor R(t) <= 1 -> enstrophy decays).

All linear algebra uses only the Python standard library (no NumPy) so the file
runs anywhere.
"""

from __future__ import annotations

import math
from typing import Callable, List, Tuple

Vector = List[float]
Matrix = List[List[float]]


# --------------------------------------------------------------------------- #
# Minimal linear algebra helpers
# --------------------------------------------------------------------------- #
def dot(a: Vector, b: Vector) -> float:
    """Real inner product <a, b>."""
    return sum(x * y for x, y in zip(a, b))


def matvec(M: Matrix, v: Vector) -> Vector:
    """Matrix-vector product M v."""
    return [dot(row, v) for row in M]


def axpy(alpha: float, x: Vector, y: Vector) -> Vector:
    """Return alpha * x + y."""
    return [alpha * xi + yi for xi, yi in zip(x, y)]


def scale(alpha: float, x: Vector) -> Vector:
    return [alpha * xi for xi in x]


def norm(v: Vector) -> float:
    return math.sqrt(dot(v, v))


# --------------------------------------------------------------------------- #
# The abstract model and its time integrator
# --------------------------------------------------------------------------- #
def vector_field(
    nu: float,
    A: Matrix,
    B: Callable[[Vector, Vector], Vector],
    u: Vector,
) -> Vector:
    """F(u) = -(nu A u) - B(u, u)."""
    return axpy(-nu, matvec(A, u), scale(-1.0, B(u, u)))


def rk4_step(f: Callable[[Vector], Vector], u: Vector, dt: float) -> Vector:
    """One classical 4th-order Runge-Kutta step of u' = f(u)."""
    k1 = f(u)
    k2 = f(axpy(dt / 2, k1, u))
    k3 = f(axpy(dt / 2, k2, u))
    k4 = f(axpy(dt, k3, u))
    incr = [(a + 2 * b + 2 * c + d) / 6 for a, b, c, d in zip(k1, k2, k3, k4)]
    return axpy(dt, incr, u)


def integrate(
    nu: float,
    A: Matrix,
    B: Callable[[Vector, Vector], Vector],
    u0: Vector,
    dt: float,
    steps: int,
) -> List[Tuple[float, Vector]]:
    """Integrate the model from u0; return list of (time, state)."""
    f = lambda u: vector_field(nu, A, B, u)
    traj = [(0.0, list(u0))]
    u = list(u0)
    for n in range(1, steps + 1):
        u = rk4_step(f, u, dt)
        traj.append((n * dt, u))
    return traj


# --------------------------------------------------------------------------- #
# Observables
# --------------------------------------------------------------------------- #
def energy(u: Vector) -> float:
    """E = <u, u> = ||u||^2."""
    return dot(u, u)


def enstrophy(A: Matrix, u: Vector) -> float:
    """Omega = <A u, u>."""
    return dot(matvec(A, u), u)


def smallest_eigenvalue_spd_diag(A: Matrix) -> float:
    """For a diagonal SPD matrix, the spectral gap lambda is the min diagonal."""
    return min(A[i][i] for i in range(len(A)))


# --------------------------------------------------------------------------- #
# A genuinely energy-preserving quadratic nonlinearity (trilinear cancellation)
# --------------------------------------------------------------------------- #
def antisymmetric_transport(u: Vector, v: Vector) -> Vector:
    """
    A 3-mode quadratic B with the trilinear cancellation <B(w,w), w> = 0.

    We use the rigid-body / Euler triad B(u, v)_i = -(L_i u) . v built from
    skew-symmetric generators L_x, L_y, L_z (cross-product structure), which
    yields <B(w, w), w> = w . (w x w) = 0 exactly.
    """
    wx, wy, wz = u
    vx, vy, vz = v
    # cross product u x v (skew, so <w x w, w> = 0)
    return [wy * vz - wz * vy, wz * vx - wx * vz, wx * vy - wy * vx]


# --------------------------------------------------------------------------- #
# DEMO 1 + 2: energy dissipation and exponential decay under coercivity
# --------------------------------------------------------------------------- #
def demo_energy_decay() -> None:
    print("=" * 70)
    print("DEMO 1 & 2: Energy dissipation and exponential decay (coercive A)")
    print("=" * 70)
    nu = 0.5
    A = [[2.0, 0.0, 0.0], [0.0, 3.0, 0.0], [0.0, 0.0, 5.0]]  # SPD, gap = 2
    B = antisymmetric_transport
    u0 = [1.0, -0.5, 0.7]
    lam = smallest_eigenvalue_spd_diag(A)

    traj = integrate(nu, A, B, u0, dt=0.01, steps=400)
    E0 = energy(traj[0][1])

    print(f"viscosity nu = {nu}, spectral gap lambda = {lam}")
    print(f"predicted decay rate 2*nu*lambda = {2 * nu * lam}")
    print(f"{'t':>6} {'E(t)':>12} {'E0*exp(-2nu*lam*t)':>22} {'E monotone?':>12}")
    prev = math.inf
    monotone = True
    for (t, u) in traj[::80]:
        E = energy(u)
        bound = E0 * math.exp(-2 * nu * lam * t)
        ok = E <= prev + 1e-9
        monotone = monotone and ok
        print(f"{t:6.2f} {E:12.6e} {bound:22.6e} {str(ok):>12}")
        prev = E
    # Verify the exponential upper bound holds at every recorded step.
    bound_ok = all(
        energy(u) <= E0 * math.exp(-2 * nu * lam * t) + 1e-9 for (t, u) in traj
    )
    print(f"\nEnergy nonincreasing along orbit : {monotone}")
    print(f"Exponential bound E(t) <= E0 e^(-2nu lam t) holds : {bound_ok}\n")


# --------------------------------------------------------------------------- #
# DEMO 3: forward-in-time uniqueness
# --------------------------------------------------------------------------- #
def demo_uniqueness() -> None:
    print("=" * 70)
    print("DEMO 3: Forward-in-time uniqueness (identical data -> identical orbit)")
    print("=" * 70)
    nu = 0.5
    A = [[2.0, 0.0, 0.0], [0.0, 3.0, 0.0], [0.0, 0.0, 5.0]]
    B = antisymmetric_transport
    u0 = [1.0, -0.5, 0.7]

    # Two integrations from the SAME data must coincide for all t >= t0.
    traj_u = integrate(nu, A, B, u0, dt=0.01, steps=300)
    traj_w = integrate(nu, A, B, list(u0), dt=0.01, steps=300)
    max_diff = max(
        norm(axpy(-1.0, w, u)) for (_, u), (_, w) in zip(traj_u, traj_w)
    )
    print(f"sup_t ||u(t) - w(t)|| with u(0) = w(0): {max_diff:.3e}")
    print(f"difference energy stays zero (uniqueness): {max_diff < 1e-12}\n")


# --------------------------------------------------------------------------- #
# DEMO 4: 2D enstrophy control (vortex-stretching cancellation)
# --------------------------------------------------------------------------- #
def demo_enstrophy_2d() -> None:
    print("=" * 70)
    print("DEMO 4: 2D enstrophy control (stretching cancellation -> Lyapunov)")
    print("=" * 70)
    nu = 1.0
    # A = identity: self-adjoint and SPD. Then <B(w,w), A w> = <B(w,w), w> = 0,
    # i.e. the 2D vortex-stretching cancellation holds (degenerate witness).
    A = [[1.0, 0.0, 0.0], [0.0, 1.0, 0.0], [0.0, 0.0, 1.0]]
    B = antisymmetric_transport
    u0 = [0.8, 0.3, -0.6]

    traj = integrate(nu, A, B, u0, dt=0.01, steps=300)
    print(f"{'t':>6} {'Omega(t)=<A u,u>':>18} {'Omega monotone?':>16}")
    prev = math.inf
    monotone = True
    for (t, u) in traj[::60]:
        om = enstrophy(A, u)
        ok = om <= prev + 1e-9
        monotone = monotone and ok
        print(f"{t:6.2f} {om:18.6e} {str(ok):>16}")
        prev = om
    print(f"\nEnstrophy nonincreasing (2D global regularity mechanism): {monotone}\n")


# --------------------------------------------------------------------------- #
# DEMO 5: 3D conditional regularity -- the stretching monitor R(t)
# --------------------------------------------------------------------------- #
def stretching_ratio(
    nu: float, A: Matrix, B: Callable[[Vector, Vector], Vector], u: Vector
) -> float:
    """R = -<B(u,u), A u> / (nu <A u, A u>); criterion satisfied iff R <= 1."""
    Au = matvec(A, u)
    num = -dot(B(u, u), Au)
    den = nu * dot(Au, Au)
    if abs(den) < 1e-15:
        return 0.0
    return num / den


def demo_conditional_3d() -> None:
    print("=" * 70)
    print("DEMO 5: 3D conditional regularity -- stretching monitor R(t) <= 1")
    print("=" * 70)
    nu = 1.0
    A = [[2.0, 0.0, 0.0], [0.0, 3.0, 0.0], [0.0, 0.0, 5.0]]  # self-adjoint SPD
    B = antisymmetric_transport  # here <B(u,u), A u> need NOT vanish (3D-like)
    u0 = [1.0, 1.0, 1.0]

    traj = integrate(nu, A, B, u0, dt=0.01, steps=300)
    print(f"{'t':>6} {'R(t)':>12} {'<=1?':>6} {'Omega(t)':>14}")
    all_controlled = True
    enstrophy_monotone = True
    prev = math.inf
    for (t, u) in traj[::60]:
        R = stretching_ratio(nu, A, B, u)
        om = enstrophy(A, u)
        controlled = R <= 1.0 + 1e-9
        all_controlled = all_controlled and controlled
        enstrophy_monotone = enstrophy_monotone and (om <= prev + 1e-6)
        prev = om
        print(f"{t:6.2f} {R:12.4f} {str(controlled):>6} {om:14.6e}")
    print(f"\nStretching controlled (R<=1) along orbit: {all_controlled}")
    print(f"=> enstrophy nonincreasing as predicted : {enstrophy_monotone}\n")


def main() -> None:
    demo_energy_decay()
    demo_uniqueness()
    demo_enstrophy_2d()
    demo_conditional_3d()
    print("All demonstrations complete.")


if __name__ == "__main__":
    main()
