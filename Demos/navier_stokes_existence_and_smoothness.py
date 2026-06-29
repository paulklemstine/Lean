"""
Numerical demonstrations for:

    "Two Anti-Blowup Mechanisms Unified:
     Viscous Energy Dissipation and Tropical Idempotency"

Both anti-blowup frameworks reduce to the SAME principle:

    A Lyapunov observable (a scalar that never increases along the evolution)
    is automatically bounded by its initial value, so the state cannot blow up.

This script verifies the principle numerically in two unrelated worlds:

  (A) The viscous Galerkin Navier-Stokes model on a real inner-product space,
      u'(t) = -nu * A u - B(u, u),  with  <A v, v> >= 0  and  <B(v,v), v> = 0.
      The energy E(t) = ||u(t)||^2 satisfies E'(t) = -2 nu <A u, u> <= 0.
      (Theorems: energy_hasDerivAt, energy_deriv_nonpos, energy_antitone,
       energy_le_initial, norm_le_initial.)

  (B) The discrete tropical (max-plus) diffusion operator
      (tropDiffMax K u)_i = max_j ( u_j - K_ij ),  K_ij >= 0,  K_ii = 0.
      The tropical energy tropEnergy(u) = max_j u_j is nonincreasing, and the
      sequence n -> tropEnergy(iterateTrop K n u) is ANTITONE.
      (Theorems: tropDiffMax_le_sup, tropEnergy_step_le,
       tropEnergy_iterate_antitone, iterate_sup_bound, osc_tropDiffMax_le_osc.)

Self-contained: only the Python standard library is used.
"""

from __future__ import annotations

import math
from typing import Callable, List, Sequence, Tuple


# ---------------------------------------------------------------------------
# (A)  Viscous Galerkin Navier-Stokes model
# ---------------------------------------------------------------------------
Vec = List[float]


def inner(u: Sequence[float], v: Sequence[float]) -> float:
    """Real inner product <u, v> on R^n."""
    return sum(a * b for a, b in zip(u, v))


def norm(u: Sequence[float]) -> float:
    """Induced norm ||u|| = sqrt(<u, u>)."""
    return math.sqrt(inner(u, u))


def viscous_operator(u: Sequence[float], nu: float) -> Vec:
    """A diagonal positive-semidefinite viscous operator A (spectral -Laplacian).

    The i-th mode is damped with rate proportional to (i+1)^2, mimicking the
    eigenvalues of -Delta. Returns nu * A u. Guarantees <A v, v> >= 0.
    """
    return [nu * ((i + 1) ** 2) * ui for i, ui in enumerate(u)]


def transport(u: Sequence[float]) -> Vec:
    """An energy-preserving quadratic nonlinearity B(u, u) on R^3.

    We use the cross-product structure B(u, u) = u x (M u) for a symmetric M.
    For any v, <v x w, v> = 0, hence the trilinear cancellation
    <B(v, v), v> = 0 holds exactly, the abstract form of the divergence-free
    transport identity. Here M = diag(1, 2, 3).
    """
    m = (1.0 * u[0], 2.0 * u[1], 3.0 * u[2])
    # cross product u x (M u)
    return [
        u[1] * m[2] - u[2] * m[1],
        u[2] * m[0] - u[0] * m[2],
        u[0] * m[1] - u[1] * m[0],
    ]


def rhs(u: Sequence[float], nu: float) -> Vec:
    """Right-hand side of u'(t) = -nu A u - B(u, u)."""
    au = viscous_operator(u, nu)
    bu = transport(u)
    return [-a - b for a, b in zip(au, bu)]


def rk4_step(u: Vec, nu: float, dt: float) -> Vec:
    """One classical fourth-order Runge-Kutta step for u' = rhs(u)."""

    def add(a: Sequence[float], b: Sequence[float], s: float) -> Vec:
        return [x + s * y for x, y in zip(a, b)]

    k1 = rhs(u, nu)
    k2 = rhs(add(u, k1, dt / 2), nu)
    k3 = rhs(add(u, k2, dt / 2), nu)
    k4 = rhs(add(u, k3, dt), nu)
    return [
        ui + (dt / 6.0) * (a + 2 * b + 2 * c + d)
        for ui, a, b, c, d in zip(u, k1, k2, k3, k4)
    ]


def simulate_viscous(u0: Vec, nu: float, dt: float, steps: int) -> List[Tuple[float, float]]:
    """Integrate the model and return [(t, energy ||u||^2)] along the trajectory."""
    u = list(u0)
    trace: List[Tuple[float, float]] = [(0.0, inner(u, u))]
    for n in range(1, steps + 1):
        u = rk4_step(u, nu, dt)
        trace.append((n * dt, inner(u, u)))
    return trace


# ---------------------------------------------------------------------------
# (B)  Discrete tropical (max-plus) diffusion
# ---------------------------------------------------------------------------
Matrix = List[List[float]]


def trop_diff_max(K: Matrix, u: Sequence[float]) -> Vec:
    """(tropDiffMax K u)_i = max_j ( u_j - K_ij )."""
    n = len(u)
    return [max(u[j] - K[i][j] for j in range(n)) for i in range(n)]


def trop_energy(u: Sequence[float]) -> float:
    """tropEnergy(u) = max_j u_j."""
    return max(u)


def osc(u: Sequence[float]) -> float:
    """Oscillation seminorm osc(u) = max u - min u."""
    return max(u) - min(u)


def iterate_trop(K: Matrix, n: int, u: Sequence[float]) -> Vec:
    """n-fold application of tropDiffMax K."""
    v = list(u)
    for _ in range(n):
        v = trop_diff_max(K, v)
    return v


def is_admissible(K: Matrix) -> bool:
    """K admissible: K_ij >= 0 for all i, j and K_ii = 0 for all i."""
    n = len(K)
    return all(K[i][j] >= 0 for i in range(n) for j in range(n)) and all(
        K[i][i] == 0 for i in range(n)
    )


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------
def demo_viscous() -> None:
    print("=" * 70)
    print("(A) Viscous Galerkin Navier-Stokes: energy is nonincreasing")
    print("=" * 70)
    u0: Vec = [3.0, -2.0, 1.5]
    nu = 0.10
    # Confirm the trilinear cancellation <B(v,v), v> = 0 numerically.
    cancel = inner(transport(u0), u0)
    print(f"trilinear cancellation  <B(u,u), u> = {cancel:+.3e}  (should be 0)")

    trace = simulate_viscous(u0, nu, dt=0.01, steps=400)
    print(f"\n{'t':>6} {'energy ||u||^2':>16} {'norm ||u||':>14}")
    for t, e in trace[::80]:
        print(f"{t:6.2f} {e:16.8f} {math.sqrt(e):14.8f}")

    energies = [e for _, e in trace]
    monotone = all(energies[k + 1] <= energies[k] + 1e-9 for k in range(len(energies) - 1))
    print(f"\nenergy nonincreasing (energy_antitone): {monotone}")
    print(f"E(T) <= E(0) (energy_le_initial): {energies[-1] <= energies[0] + 1e-9}")
    print(
        "||u(T)|| <= ||u(0)|| (norm_le_initial): "
        f"{math.sqrt(energies[-1]) <= math.sqrt(energies[0]) + 1e-9}"
    )


def demo_tropical() -> None:
    print("\n" + "=" * 70)
    print("(B) Tropical diffusion: tropical energy is ANTITONE")
    print("=" * 70)
    # A nonnegative, zero-diagonal cost matrix (admissible).
    K: Matrix = [
        [0.0, 0.5, 1.0, 1.5],
        [0.5, 0.0, 0.5, 1.0],
        [1.0, 0.5, 0.0, 0.5],
        [1.5, 1.0, 0.5, 0.0],
    ]
    print(f"K admissible (K_ij >= 0, K_ii = 0): {is_admissible(K)}")

    u: Vec = [4.0, 1.0, -2.0, 0.5]
    print(f"\ninitial state u = {u}")
    print(f"\n{'n':>3} {'iterate':>34} {'tropEnergy':>12} {'osc':>10}")
    energies: List[float] = []
    oscs: List[float] = []
    for n in range(0, 6):
        v = iterate_trop(K, n, u)
        e = trop_energy(v)
        o = osc(v)
        energies.append(e)
        oscs.append(o)
        formatted = "[" + ", ".join(f"{x:5.2f}" for x in v) + "]"
        print(f"{n:3d} {formatted:>34} {e:12.6f} {o:10.6f}")

    antitone = all(energies[k + 1] <= energies[k] + 1e-12 for k in range(len(energies) - 1))
    osc_contract = all(oscs[k + 1] <= oscs[k] + 1e-12 for k in range(len(oscs) - 1))
    print(f"\ntropEnergy antitone (tropEnergy_iterate_antitone): {antitone}")
    print(f"each iterate <= initial (iterate_sup_bound): {all(e <= energies[0] + 1e-12 for e in energies)}")
    print(f"oscillation contracts (osc_tropDiffMax_le_osc): {osc_contract}")


def demo_bridge() -> None:
    print("\n" + "=" * 70)
    print("Unified no-blowup (viscous_and_tropical_no_blowup)")
    print("=" * 70)
    # Viscous half.
    u0: Vec = [2.0, 2.0, -1.0]
    trace = simulate_viscous(u0, nu=0.2, dt=0.01, steps=200)
    visc_ok = math.sqrt(trace[-1][1]) <= math.sqrt(trace[0][1]) + 1e-9
    # Tropical half.
    K: Matrix = [[0.0, 1.0, 2.0], [1.0, 0.0, 1.0], [2.0, 1.0, 0.0]]
    w: Vec = [5.0, 0.0, -3.0]
    trop_ok = trop_energy(iterate_trop(K, 4, w)) <= trop_energy(w) + 1e-12
    print(f"||u(t)|| <= ||u(s)||           : {visc_ok}")
    print(f"tropEnergy(iter^n w) <= tropEnergy(w): {trop_ok}")
    print(f"both conclusions hold simultaneously : {visc_ok and trop_ok}")


def main() -> None:
    demo_viscous()
    demo_tropical()
    demo_bridge()


if __name__ == "__main__":
    main()
