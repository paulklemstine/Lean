"""Numerical demonstrations of inhomogeneous (noisy) minicenter Delaunay refinement.

This script exercises the *main theorem* of the package numerically: the exact
closed-form upper bound

    d_k <= a**k * d0 + b * (1 - a**k) / (1 - a)            (Theorem `d_le_closedForm`)

for an inhomogeneous contraction process

    d_{k+1} <= a * d_k + b,   0 <= a < 1,   b >= 0          (`InhomogeneousContractionProcess`)

together with its corollaries: geometric decay of the transient toward the
attractor radius L = b/(1-a) (`excess_le_pow`), two-sided convergence under the
exact recurrence (`tendsto_of_exact`, `dist_le_pow_of_exact`), uniform trapping
(`d_le_uniform`), and the homogeneous edge-bisection base case (`segmentBisection`).

All functions are self-contained and type-hinted; the script prints a report and
asserts each theorem on the generated trajectories.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Callable, List


# --------------------------------------------------------------------------- #
# Core model
# --------------------------------------------------------------------------- #
def fixed_point(a: float, b: float) -> float:
    """Attractor radius L = b / (1 - a) (Lean `fixedPoint`). Requires a < 1."""
    if not (0.0 <= a < 1.0):
        raise ValueError("need 0 <= a < 1")
    return b / (1.0 - a)


def closed_form_bound(a: float, b: float, d0: float, k: int) -> float:
    """Closed-form upper bound a**k * d0 + b*(1-a**k)/(1-a) (Lean `d_le_closedForm`)."""
    return a ** k * d0 + b * (1.0 - a ** k) / (1.0 - a)


def exact_trajectory(a: float, b: float, d0: float, n: int) -> List[float]:
    """The affine iteration d_{k+1} = a*d_k + b for k = 0..n (Lean `affineIteration`)."""
    d = d0
    out = [d]
    for _ in range(n):
        d = a * d + b
        out.append(d)
    return out


def perturbed_trajectory(
    a: float,
    b: float,
    d0: float,
    n: int,
    perturb: Callable[[int], float],
) -> List[float]:
    """A trajectory obeying the *inequality* d_{k+1} = a*d_k + delta_k with 0 <= delta_k <= b.

    `perturb(k)` must return a value in [0, b]; this models bounded but
    sub-maximal Steiner-point noise, satisfying d_{k+1} <= a*d_k + b.
    """
    d = d0
    out = [d]
    for k in range(n):
        delta = perturb(k)
        if not (0.0 <= delta <= b):
            raise ValueError("perturbation must lie in [0, b]")
        d = a * d + delta
        out.append(d)
    return out


@dataclass(frozen=True)
class TheoremReport:
    """Outcome of verifying the theorems on one trajectory."""
    closed_form_holds: bool
    transient_holds: bool
    uniform_band_holds: bool
    per_step_holds: bool


def verify(a: float, b: float, d0: float, traj: List[float], tol: float = 1e-9) -> TheoremReport:
    """Check the main theorems numerically on a given (sub-maximal) trajectory."""
    L = fixed_point(a, b)
    cf = all(traj[k] <= closed_form_bound(a, b, d0, k) + tol for k in range(len(traj)))
    transient = all(traj[k] - L <= a ** k * (d0 - L) + tol for k in range(len(traj)))
    band = all(0.0 - tol <= dk <= d0 + L + tol for dk in traj)
    per_step = all(traj[k + 1] <= a * traj[k] + b + tol for k in range(len(traj) - 1))
    return TheoremReport(cf, transient, band, per_step)


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #
def demo_convergence_to_attractor() -> None:
    """Exact recurrence converges to L = b/(1-a) at the sharp rate a**k."""
    a, b, d0 = 0.5, 1.0, 100.0
    L = fixed_point(a, b)
    traj = exact_trajectory(a, b, d0, 25)
    print("== Exact noisy refinement: a=0.5, b=1.0, d0=100 ==")
    print(f"attractor radius L = b/(1-a) = {L:.6f}")
    for k in (0, 1, 5, 10, 20):
        dk = traj[k]
        rate = a ** k * abs(d0 - L)
        print(f"  k={k:2d}  d_k={dk:12.6f}  |d_k - L|={abs(dk - L):.3e} <= a^k|d0-L|={rate:.3e}")
        assert abs(dk - L) <= rate + 1e-9  # dist_le_pow_of_exact
    assert abs(traj[-1] - L) < 1e-3
    print("  -> converged to attractor.\n")


def demo_inequality_one_sided() -> None:
    """The inequality model only traps in [0, L+eps]; d == 0 is a valid sub-floor trajectory."""
    a, b, d0 = 0.7, 2.0, 50.0
    L = fixed_point(a, b)
    # Sub-maximal noise: half the maximal defect each step.
    traj = perturbed_trajectory(a, b, d0, 30, perturb=lambda k: 0.5 * b)
    rep = verify(a, b, d0, traj)
    print("== Inequality model: a=0.7, b=2.0, d0=50, delta_k = b/2 ==")
    print(f"  L = {L:.4f}  (steady state of the *maximal* recurrence)")
    print(f"  closed-form bound holds : {rep.closed_form_holds}")
    print(f"  transient bound holds   : {rep.transient_holds}")
    print(f"  uniform band [0,d0+L]   : {rep.uniform_band_holds}")
    print(f"  per-step <= a*d_k + b   : {rep.per_step_holds}")
    assert all([rep.closed_form_holds, rep.transient_holds, rep.uniform_band_holds, rep.per_step_holds])
    # The all-zero trajectory also satisfies the inequality but does not reach L.
    zero = [0.0] * 30
    rep0 = verify(a, b, 0.0, zero)
    print(f"  zero trajectory satisfies inequality: {rep0.per_step_holds} (never reaches L>0)\n")


def demo_homogeneous_edge_bisection() -> None:
    """Noiseless base case: edge bisection gives d_k = D/2^k, lambda = 2 (segmentBisection)."""
    D = 8.0
    a, b = 0.5, 0.0  # lambda = 2 => a = 1/2, no defect
    traj = exact_trajectory(a, b, D, 6)
    print("== Homogeneous edge bisection: D=8, lambda=2 (b=0) ==")
    for k, dk in enumerate(traj):
        print(f"  k={k}  d_k={dk:.6f}  D/2^k={D / 2 ** k:.6f}")
        assert abs(dk - D / 2 ** k) < 1e-12
        assert dk <= (1.0 / 2.0) ** k * D + 1e-12  # diam_le_pow
    print("  -> exponential decay to 0 (L = 0).\n")


def demo_floor_scaling() -> None:
    """The attractor floor scales linearly in b and is controlled by 1-a."""
    print("== Floor L = b/(1-a) scaling ==")
    for a in (0.5, 0.9, 0.99):
        for b in (1.0, 0.5):
            print(f"  a={a:5.2f}, b={b:4.2f} -> L={fixed_point(a, b):10.4f}")
    print("  -> halving b halves the floor; a->1 inflates it.\n")


if __name__ == "__main__":
    demo_convergence_to_attractor()
    demo_inequality_one_sided()
    demo_homogeneous_edge_bisection()
    demo_floor_scaling()
    print("All theorem checks passed.")
