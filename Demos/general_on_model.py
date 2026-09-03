#!/usr/bin/env python3
"""
Numerical demonstrations for the critical exponents of the O(N) model,
uniformly in the symmetry index N.

Everything in this file is derived from a single one-loop beta function

    beta_N(eps, g) = -eps * g + ((N + 8) / 3) * g**2,

whose only zeros are the Gaussian coupling g = 0 and the Wilson-Fisher
coupling g* = 3*eps/(N + 8).  Substituting g* into the standard scaling
functions produces the first terms of the critical exponents as explicit
rational functions of N:

    eta   = (N+2) eps^2 / (2 (N+8)^2)
    nu    = 1/2 + (N+2) eps / (4 (N+8))
    gamma = 1 + (N+2) eps / (2 (N+8))
    alpha = (4-N) eps / (2 (N+8))
    beta  = 1/2 - 3 eps / (2 (N+8))
    delta = 3 + eps
    omega = eps

The script verifies, numerically and to machine precision:

  1. the fixed-point classification and the value of g*;
  2. reduction to the classical one-component (Ising) values at N = 1;
  3. omega = d(beta_N)/dg at g*, equal to eps for every N;
  4. maximality of the eta coefficient exactly at N = 4, value 1/48;
  5. the sign flip of the specific-heat exponent exactly at N = 4;
  6. Rushbrooke's relation as an exact identity in (N, eps);
  7. the closed-form deficits of Fisher, Josephson and Widom;
  8. the coupling-exponent identity 3 eta = (2 nu - 1) g*;
  9. large-N limits and agreement with the exactly solvable spherical model;
 10. convergence of the discrete infrared flow to g*, N-uniformly;
 11. two-loop existence with an N-independent O(eps^3) remainder constant.

Requires only the Python standard library.
"""

from __future__ import annotations

import math
from typing import Callable, Dict, Iterable, List, Sequence, Tuple

TOL: float = 1e-12


# ---------------------------------------------------------------------------
# 1. The one-loop flow
# ---------------------------------------------------------------------------


def beta_one_loop(n_sym: float, eps: float, g: float) -> float:
    """One-loop beta function -eps*g + ((N+8)/3) g^2."""
    return -eps * g + ((n_sym + 8.0) / 3.0) * g * g


def beta_derivative(n_sym: float, eps: float, g: float) -> float:
    """Exact derivative d(beta)/dg = -eps + 2 ((N+8)/3) g."""
    return -eps + 2.0 * ((n_sym + 8.0) / 3.0) * g


def fixed_point(n_sym: float, eps: float) -> float:
    """Wilson-Fisher coupling g* = 3 eps / (N + 8)."""
    return 3.0 * eps / (n_sym + 8.0)


def beta_two_loop(n_sym: float, c_two: float, eps: float, g: float) -> float:
    """Two-loop beta function -eps*g + ((N+8)/3) g^2 - c g^3."""
    return beta_one_loop(n_sym, eps, g) - c_two * g ** 3


def two_loop_coeff(n_sym: float) -> float:
    """Standard two-loop coefficient c(N) = (3N + 14)/9 in this normalisation."""
    return (3.0 * n_sym + 14.0) / 9.0


# ---------------------------------------------------------------------------
# 2. The critical exponents
# ---------------------------------------------------------------------------


def eta_exponent(n_sym: float, eps: float) -> float:
    """Anomalous dimension eta = (N+2) eps^2 / (2 (N+8)^2)."""
    return (n_sym + 2.0) * eps ** 2 / (2.0 * (n_sym + 8.0) ** 2)


def nu_exponent(n_sym: float, eps: float) -> float:
    """Correlation-length exponent nu = 1/2 + (N+2) eps / (4 (N+8))."""
    return 0.5 + (n_sym + 2.0) * eps / (4.0 * (n_sym + 8.0))


def inv_nu_at_fixed_point(n_sym: float, eps: float) -> float:
    """1/nu evaluated at the fixed point: 2 - (N+2) eps / (N+8)."""
    return 2.0 - (n_sym + 2.0) * eps / (n_sym + 8.0)


def gamma_exponent(n_sym: float, eps: float) -> float:
    """Susceptibility exponent gamma = 1 + (N+2) eps / (2 (N+8))."""
    return 1.0 + (n_sym + 2.0) * eps / (2.0 * (n_sym + 8.0))


def alpha_exponent(n_sym: float, eps: float) -> float:
    """Specific-heat exponent alpha = (4-N) eps / (2 (N+8))."""
    return (4.0 - n_sym) * eps / (2.0 * (n_sym + 8.0))


def beta_op_exponent(n_sym: float, eps: float) -> float:
    """Order-parameter exponent beta = 1/2 - 3 eps / (2 (N+8))."""
    return 0.5 - 3.0 * eps / (2.0 * (n_sym + 8.0))


def delta_exponent(eps: float) -> float:
    """Critical-isotherm exponent delta = 3 + eps (independent of N)."""
    return 3.0 + eps


def omega_exponent(eps: float) -> float:
    """Correction-to-scaling exponent omega = eps (independent of N)."""
    return eps


def all_exponents(n_sym: float, eps: float) -> Dict[str, float]:
    """Return the full exponent dictionary at given (N, eps)."""
    return {
        "g*": fixed_point(n_sym, eps),
        "eta": eta_exponent(n_sym, eps),
        "nu": nu_exponent(n_sym, eps),
        "gamma": gamma_exponent(n_sym, eps),
        "alpha": alpha_exponent(n_sym, eps),
        "beta": beta_op_exponent(n_sym, eps),
        "delta": delta_exponent(eps),
        "omega": omega_exponent(eps),
    }


# Leading coefficients as functions of N alone.


def eta_coeff(n_sym: float) -> float:
    """eta_2(N) = (N+2) / (2 (N+8)^2), the coefficient of eps^2 in eta."""
    return (n_sym + 2.0) / (2.0 * (n_sym + 8.0) ** 2)


def nu_coeff(n_sym: float) -> float:
    """nu_1(N) = (N+2) / (4 (N+8)), the coefficient of eps in nu."""
    return (n_sym + 2.0) / (4.0 * (n_sym + 8.0))


def alpha_coeff(n_sym: float) -> float:
    """alpha_1(N) = (4-N) / (2 (N+8)), the coefficient of eps in alpha."""
    return (4.0 - n_sym) / (2.0 * (n_sym + 8.0))


# ---------------------------------------------------------------------------
# 3. Reporting helpers
# ---------------------------------------------------------------------------


def banner(title: str) -> None:
    print()
    print("=" * 74)
    print(title)
    print("=" * 74)


def check(label: str, lhs: float, rhs: float, tol: float = TOL) -> bool:
    """Print and return the outcome of a numerical equality assertion."""
    ok = abs(lhs - rhs) <= tol * max(1.0, abs(lhs), abs(rhs))
    mark = "OK " if ok else "FAIL"
    print(f"  [{mark}] {label:<52s} {lhs: .12f}  vs {rhs: .12f}")
    return ok


# ---------------------------------------------------------------------------
# Demo 1: fixed-point classification and reduction at N = 1
# ---------------------------------------------------------------------------


def demo_fixed_points() -> None:
    banner("1.  Fixed points of the one-loop flow, and the Ising slice")
    eps = 1.0
    print("  beta_N(eps, g) = -eps g + ((N+8)/3) g^2 ;  eps = 1")
    print()
    print(f"  {'N':>6s} {'g*':>12s} {'beta(g*)':>14s} {'beta(0)':>10s}"
          f" {'slope at 0':>12s} {'slope at g*':>12s}")
    for n_sym in (0.0, 1.0, 2.0, 3.0, 4.0, 10.0, 100.0):
        g_star = fixed_point(n_sym, eps)
        print(f"  {n_sym:6.0f} {g_star:12.8f} {beta_one_loop(n_sym, eps, g_star):14.2e}"
              f" {beta_one_loop(n_sym, eps, 0.0):10.2e}"
              f" {beta_derivative(n_sym, eps, 0.0):12.6f}"
              f" {beta_derivative(n_sym, eps, g_star):12.6f}")
    print()
    print("  The Gaussian point has slope -eps < 0 (infrared-repulsive);")
    print("  the Wilson-Fisher point has slope exactly +eps > 0 for EVERY N.")
    print()
    print("  Reduction to the one-component (Ising) theory at N = 1, eps = 1:")
    check("g*(1, 1) = 1/3", fixed_point(1.0, 1.0), 1.0 / 3.0)
    check("eta(1, 1) = 1/54", eta_exponent(1.0, 1.0), 1.0 / 54.0)
    check("nu(1, 1) = 1/2 + 1/12", nu_exponent(1.0, 1.0), 0.5 + 1.0 / 12.0)
    check("gamma(1, 1) = 1 + 1/6", gamma_exponent(1.0, 1.0), 1.0 + 1.0 / 6.0)
    check("alpha(1, 1) = 1/6", alpha_exponent(1.0, 1.0), 1.0 / 6.0)
    check("beta(1, 1) = 1/2 - 1/6", beta_op_exponent(1.0, 1.0), 0.5 - 1.0 / 6.0)


# ---------------------------------------------------------------------------
# Demo 2: omega is the slope, universally
# ---------------------------------------------------------------------------


def numerical_derivative(f: Callable[[float], float], x: float,
                         h: float = 1e-6) -> float:
    """Central finite difference."""
    return (f(x + h) - f(x - h)) / (2.0 * h)


def demo_omega_universality() -> None:
    banner("2.  omega = d(beta)/dg at the fixed point equals eps for every N")
    for eps in (0.25, 0.5, 1.0):
        print(f"  eps = {eps}")
        for n_sym in (0.0, 1.0, 3.0, 7.0, 50.0):
            g_star = fixed_point(n_sym, eps)
            num = numerical_derivative(lambda g: beta_one_loop(n_sym, eps, g), g_star)
            check(f"N = {n_sym:<5g}  finite-difference slope = eps",
                  num, omega_exponent(eps), tol=1e-6)


# ---------------------------------------------------------------------------
# Demo 3: the extremum at N = 4
# ---------------------------------------------------------------------------


def demo_extremum_at_four() -> None:
    banner("3.  The anomalous-dimension coefficient peaks exactly at N = 4")
    print("  eta_2(N) = (N+2) / (2 (N+8)^2);   claim: max = 1/48 at N = 4")
    print()
    print(f"  {'N':>8s} {'eta_2(N)':>14s} {'1/48 - eta_2':>16s} "
          f"{'alpha_1(N)':>12s}")
    grid: List[float] = [0.0, 1.0, 2.0, 3.0, 3.5, 4.0, 4.5, 5.0, 8.0, 20.0, 200.0]
    for n_sym in grid:
        print(f"  {n_sym:8.2f} {eta_coeff(n_sym):14.10f} "
              f"{1.0 / 48.0 - eta_coeff(n_sym):16.3e} {alpha_coeff(n_sym):12.6f}")
    print()
    # Fine scan to locate the maximiser numerically.
    best_n, best_v = -8.0, -math.inf
    n_val = 0.0
    while n_val <= 12.0:
        v = eta_coeff(n_val)
        if v > best_v:
            best_n, best_v = n_val, v
        n_val += 1e-4
    check("numerical argmax of eta_2 equals 4", best_n, 4.0, tol=1e-3)
    check("numerical max of eta_2 equals 1/48", best_v, 1.0 / 48.0, tol=1e-8)
    print()
    print("  The SAME value N = 4 is where the specific-heat exponent changes sign:")
    for n_sym, expect in ((3.9, "> 0"), (4.0, "= 0"), (4.1, "< 0")):
        a = alpha_exponent(n_sym, 1.0)
        print(f"    alpha(N = {n_sym}, eps = 1) = {a: .8f}   (expected {expect})")
    print()
    print("  Uniform bound: eta <= eps^2/48 for all N >= 0.")
    worst = max(eta_exponent(n / 10.0, 1.0) for n in range(0, 2001))
    check("max over N in [0, 200] of eta(N, 1)", worst, 1.0 / 48.0, tol=1e-6)


# ---------------------------------------------------------------------------
# Demo 4: scaling relations, exact and deficient
# ---------------------------------------------------------------------------


def demo_scaling_relations() -> None:
    banner("4.  Scaling relations: which are exact, and the closed-form deficits")
    for n_sym, eps in ((0.0, 1.0), (1.0, 0.5), (3.0, 1.0), (7.5, 0.25), (40.0, 1.0)):
        a = alpha_exponent(n_sym, eps)
        b = beta_op_exponent(n_sym, eps)
        g = gamma_exponent(n_sym, eps)
        nu = nu_exponent(n_sym, eps)
        et = eta_exponent(n_sym, eps)
        de = delta_exponent(eps)
        print(f"  N = {n_sym:<6g} eps = {eps:<5g}")
        check("Rushbrooke  alpha + 2 beta + gamma = 2 (exact)", a + 2 * b + g, 2.0)
        check("gamma = 2 nu (exact)", g, 2.0 * nu)
        check("Fisher deficit  gamma - nu(2-eta) = nu*eta",
              g - nu * (2.0 - et), nu * et)
        check("Josephson deficit  (2-alpha) - (4-eps) nu",
              (2.0 - a) - (4.0 - eps) * nu,
              (n_sym + 2.0) * eps ** 2 / (4.0 * (n_sym + 8.0)))
        check("Widom deficit  1 + gamma/beta - delta",
              1.0 + g / b - de,
              3.0 * eps ** 2 / (n_sym + 8.0 - 3.0 * eps))
        check("coupling identity  3 eta = (2 nu - 1) g*",
              3.0 * et, (2.0 * nu - 1.0) * fixed_point(n_sym, eps))
        check("reciprocality  nu * (1/nu) = 1 - ((N+2)eps/(2(N+8)))^2",
              nu * inv_nu_at_fixed_point(n_sym, eps),
              1.0 - (n_sym + 2.0) ** 2 * eps ** 2 / (4.0 * (n_sym + 8.0) ** 2))
        check("affine invariant  alpha = 2 - 4 nu + eps/2",
              a, 2.0 - 4.0 * nu + eps / 2.0)
        print()
    print("  Note the Widom deficit numerator 3 eps^2 carries no N at all,")
    print("  and every relation that is AFFINE in the exponents is exact.")


# ---------------------------------------------------------------------------
# Demo 5: large N and the spherical model
# ---------------------------------------------------------------------------


def demo_large_n() -> None:
    banner("5.  Large N: convergence to the exactly solvable spherical model")
    eps = 1.0
    print("  Spherical model (N = infinity), exact in d = 4 - eps:")
    print("    nu_sph = 1/(d-2) = 1/(2-eps),  alpha_sph = (d-4)/(d-2) = -eps/(2-eps),"
          "  eta_sph = 0")
    print()
    print(f"  {'N':>10s} {'eta_2(N)':>12s} {'nu_1(N)':>12s} {'alpha_1(N)':>12s}")
    for n_sym in (1.0, 10.0, 100.0, 1e3, 1e5, 1e8):
        print(f"  {n_sym:10.0f} {eta_coeff(n_sym):12.3e} {nu_coeff(n_sym):12.8f} "
              f"{alpha_coeff(n_sym):12.8f}")
    print(f"  {'limit':>10s} {0.0:12.3e} {0.25:12.8f} {-0.5:12.8f}")
    print()
    for eps in (0.25, 0.5, 1.0):
        nu_series = 0.5 + eps / 4.0
        nu_exact = 1.0 / (2.0 - eps)
        al_series = -eps / 2.0
        al_exact = -eps / (2.0 - eps)
        check(f"eps={eps}: exact nu-gap = eps^2/(4(2-eps))",
              nu_exact - nu_series, eps ** 2 / (4.0 * (2.0 - eps)))
        print(f"        |gap| = {abs(nu_exact - nu_series):.6f} "
              f"<= eps^2/4 = {eps ** 2 / 4.0:.6f}  "
              f"{'OK' if abs(nu_exact - nu_series) <= eps ** 2 / 4 + TOL else 'FAIL'}")
        check(f"eps={eps}: exact alpha-gap = -eps^2/(2(2-eps))",
              al_exact - al_series, -eps ** 2 / (2.0 * (2.0 - eps)))
        print(f"        |gap| = {abs(al_exact - al_series):.6f} "
              f"<= eps^2/2 = {eps ** 2 / 2.0:.6f}  "
              f"{'OK' if abs(al_exact - al_series) <= eps ** 2 / 2 + TOL else 'FAIL'}")
    print()
    print("  The distinguished value N = -2 (Gaussian locus):")
    check("eta_2(-2) = 0", eta_coeff(-2.0), 0.0)
    check("nu_1(-2)  = 0", nu_coeff(-2.0), 0.0)


# ---------------------------------------------------------------------------
# Demo 6: the discrete infrared flow converges to Wilson-Fisher
# ---------------------------------------------------------------------------


def flow_iterate(n_sym: float, eps: float, step: float, g0: float,
                 n_steps: int) -> List[float]:
    """Discrete infrared Euler flow g_{k+1} = g_k - h beta_N(eps, g_k)."""
    seq: List[float] = [g0]
    g = g0
    for _ in range(n_steps):
        g = g - step * beta_one_loop(n_sym, eps, g)
        seq.append(g)
    return seq


def demo_flow_convergence() -> None:
    banner("6.  The discrete infrared flow: Wilson-Fisher is the attractor")
    eps = 1.0
    print("  g_{k+1} = g_k - h beta_N(eps, g_k),  0 < h <= 1/eps,  g_0 in (0, g*)")
    print("  The basin (0, g*) and the step range are the same for every N >= 0.")
    print()
    for n_sym in (0.0, 1.0, 3.0, 20.0):
        g_star = fixed_point(n_sym, eps)
        for step in (0.25, 1.0):
            g0 = 0.01 * g_star
            seq = flow_iterate(n_sym, eps, step, g0, 4000)
            # non-decreasing overall, and strictly increasing until the
            # sequence saturates at g* to machine precision
            monotone = all(seq[k] <= seq[k + 1] for k in range(len(seq) - 1))
            strict_early = all(seq[k] < seq[k + 1]
                               for k in range(len(seq) - 1)
                               if seq[k] < g_star - 1e-15)
            inside = all(0.0 < x < g_star + TOL for x in seq)
            print(f"  N = {n_sym:<5g} h = {step:<5g}  g* = {g_star:.8f}  "
                  f"limit = {seq[-1]:.8f}  "
                  f"|err| = {abs(seq[-1] - g_star):.2e}  "
                  f"monotone = {monotone}  strictly rising = {strict_early}  "
                  f"in basin = {inside}")


# ---------------------------------------------------------------------------
# Demo 7: two loops, with an N-independent remainder constant
# ---------------------------------------------------------------------------


def bisect_root(f: Callable[[float], float], lo: float, hi: float,
                iters: int = 200) -> float:
    """Bisection for a sign-changing continuous function on [lo, hi]."""
    f_lo = f(lo)
    for _ in range(iters):
        mid = 0.5 * (lo + hi)
        f_mid = f(mid)
        if (f_lo > 0.0) == (f_mid > 0.0):
            lo, f_lo = mid, f_mid
        else:
            hi = mid
    return 0.5 * (lo + hi)


def demo_two_loop() -> None:
    banner("7.  Two loops: exact root vs prediction, with N-uniform remainder")
    print("  beta_N = -eps g + a g^2 - c g^3,  a = (N+8)/3,  c = (3N+14)/9")
    print("  prediction: g* = 3 eps/(N+8) + 27 c eps^2/(N+8)^3,  error <= eps^3")
    print()
    header = (f"  {'N':>6s} {'eps':>6s} {'one-loop':>12s} {'exact root':>13s}"
              f" {'prediction':>13s} {'|err|':>11s} {'eps^3':>10s} {'12c^2/a^5':>11s}")
    print(header)
    for n_sym in (0.0, 1.0, 3.0, 10.0, 100.0):
        for eps in (0.2, 4.0 / 7.0):
            a = (n_sym + 8.0) / 3.0
            c = two_loop_coeff(n_sym)
            one_loop = eps / a
            pred = one_loop + c * eps ** 2 / a ** 3
            # the non-Gaussian zero solves c r^2 - a r + eps = 0 on [eps/a, 2eps/a]
            root = bisect_root(lambda r: c * r * r - a * r + eps,
                               eps / a, 2.0 * eps / a)
            err = abs(root - pred)
            residual = beta_two_loop(n_sym, c, eps, root)
            assert abs(residual) < 1e-10, residual
            assert root >= one_loop - TOL
            assert err <= eps ** 3 + TOL
            print(f"  {n_sym:6.0f} {eps:6.3f} {one_loop:12.8f} {root:13.9f}"
                  f" {pred:13.9f} {err:11.3e} {eps ** 3:10.3e}"
                  f" {12 * c ** 2 / a ** 5:11.4f}")
    print()
    print("  The last column is the a-priori remainder constant 12 c^2 / a^5.")
    print("  It stays below 1 for every N >= 0 because a = (N+8)/3 enters to the")
    print("  fifth power while c grows only linearly: the two-loop remainder is")
    print("  uniform BECAUSE the fixed-point coupling shrinks like 1/N.")
    print()
    print("  Two-loop correction always pushes the coupling up:")
    for n_sym in (0.0, 2.0, 9.0):
        one = fixed_point(n_sym, 0.5)
        two = one + 27.0 * two_loop_coeff(n_sym) * 0.25 / (n_sym + 8.0) ** 3
        print(f"    N = {n_sym:<4g}  one-loop {one:.8f}  <  two-loop {two:.8f}")


# ---------------------------------------------------------------------------
# Demo 8: the master table at eps = 1
# ---------------------------------------------------------------------------


def demo_table() -> None:
    banner("8.  The exponent table at eps = 1 (three dimensions)")
    print(f"  {'N':>8s} {'g*':>9s} {'eta':>9s} {'nu':>9s} {'gamma':>9s}"
          f" {'alpha':>9s} {'beta':>9s} {'delta':>7s} {'omega':>7s}")
    rows: Sequence[float] = (0.0, 1.0, 2.0, 3.0, 4.0, 10.0, 1e9)
    for n_sym in rows:
        e = all_exponents(n_sym, 1.0)
        label = "inf" if n_sym > 1e8 else f"{n_sym:.0f}"
        print(f"  {label:>8s} {e['g*']:9.4f} {e['eta']:9.5f} {e['nu']:9.4f}"
              f" {e['gamma']:9.4f} {e['alpha']:9.4f} {e['beta']:9.4f}"
              f" {e['delta']:7.2f} {e['omega']:7.2f}")
    print()
    print("  Reference three-dimensional estimates for comparison:")
    print("    Ising     (N=1):  nu ~ 0.630, gamma ~ 1.237, eta ~ 0.036")
    print("    XY        (N=2):  nu ~ 0.672, gamma ~ 1.318, eta ~ 0.038")
    print("    Heisenberg(N=3):  nu ~ 0.711, gamma ~ 1.396, eta ~ 0.037")
    print("  A first-order truncation evaluated at eps = 1 captures the correct")
    print("  ordering and the correct direction of departure from mean field.")


# ---------------------------------------------------------------------------


def main() -> None:
    print("Critical exponents of the O(N) model, uniformly in N")
    print("One-loop beta function: beta_N(eps, g) = -eps g + ((N+8)/3) g^2")
    demo_fixed_points()
    demo_omega_universality()
    demo_extremum_at_four()
    demo_scaling_relations()
    demo_large_n()
    demo_flow_convergence()
    demo_two_loop()
    demo_table()
    banner("All numerical checks completed.")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Algorithm: Wilson-Fisher Exponent Evaluation from the One-Loop Beta Function.

Given a symmetry index N and a dimensional deficit eps (with d = 4 - eps),
this routine locates the non-Gaussian zero of the one-loop beta function
by exact factorisation, substitutes it into the scaling functions, and
returns the full first-order critical-exponent vector together with the
exact deficits of the four classical scaling relations.

Complexity: O(1) arithmetic operations per (N, eps) pair; the table over a
grid of M values of N costs O(M).
"""

from __future__ import annotations

from typing import Dict, List, Sequence, Tuple


def wilson_fisher_coupling(n_sym: float, eps: float) -> float:
    """Non-Gaussian zero of -eps g + ((N+8)/3) g^2, obtained by factorisation.

    Raises ValueError at the excluded point N = -8, where the quadratic
    coefficient vanishes and the fixed point escapes to infinity.
    """
    if abs(n_sym + 8.0) < 1e-300:
        raise ValueError("N = -8 is excluded: the one-loop fixed point diverges")
    return 3.0 * eps / (n_sym + 8.0)


def exponent_vector(n_sym: float, eps: float) -> Dict[str, float]:
    """Full first-order exponent vector at (N, eps)."""
    d_den = n_sym + 8.0
    g_star = wilson_fisher_coupling(n_sym, eps)
    eta = (n_sym + 2.0) / 18.0 * g_star ** 2          # two-loop anomalous dim.
    inv_nu = 2.0 - (n_sym + 2.0) / 3.0 * g_star       # one-loop 1/nu
    nu = 0.5 + (n_sym + 2.0) * eps / (4.0 * d_den)    # truncated reciprocal
    return {
        "g_star": g_star,
        "eta": eta,
        "inv_nu": inv_nu,
        "nu": nu,
        "gamma": 1.0 + (n_sym + 2.0) * eps / (2.0 * d_den),
        "alpha": (4.0 - n_sym) * eps / (2.0 * d_den),
        "beta": 0.5 - 3.0 * eps / (2.0 * d_den),
        "delta": 3.0 + eps,
        "omega": eps,
    }


def scaling_deficits(n_sym: float, eps: float) -> Dict[str, Tuple[float, float]]:
    """Deficits of the four classical scaling relations, measured and predicted.

    Returns a dictionary mapping the relation name to the pair
    (measured deficit, closed-form prediction).  Rushbrooke's prediction is
    exactly zero; the other three are the O(eps^2) closed forms.
    """
    e = exponent_vector(n_sym, eps)
    a, b, g = e["alpha"], e["beta"], e["gamma"]
    nu, eta, delta = e["nu"], e["eta"], e["delta"]
    return {
        "Rushbrooke  (alpha + 2 beta + gamma) - 2": (a + 2 * b + g - 2.0, 0.0),
        "Fisher      gamma - nu(2 - eta)": (g - nu * (2.0 - eta), nu * eta),
        "Josephson   (2 - alpha) - (4 - eps) nu": (
            (2.0 - a) - (4.0 - eps) * nu,
            (n_sym + 2.0) * eps ** 2 / (4.0 * (n_sym + 8.0)),
        ),
        "Widom       1 + gamma/beta - delta": (
            1.0 + g / b - delta,
            3.0 * eps ** 2 / (n_sym + 8.0 - 3.0 * eps),
        ),
    }


def exponent_table(n_values: Sequence[float], eps: float) -> List[Dict[str, float]]:
    """Exponent vectors across a grid of symmetry indices."""
    return [dict(N=n, **exponent_vector(n, eps)) for n in n_values]


def main() -> None:
    eps = 1.0
    grid: List[float] = [0.0, 1.0, 2.0, 3.0, 4.0, 5.0, 10.0, 100.0]
    print(f"First-order O(N) critical exponents at eps = {eps} (d = {4 - eps})")
    print(f"{'N':>6s} {'g*':>9s} {'eta':>9s} {'nu':>9s} {'gamma':>9s} "
          f"{'alpha':>9s} {'beta':>9s} {'delta':>7s} {'omega':>7s}")
    for row in exponent_table(grid, eps):
        print(f"{row['N']:6.0f} {row['g_star']:9.4f} {row['eta']:9.5f} "
              f"{row['nu']:9.4f} {row['gamma']:9.4f} {row['alpha']:9.4f} "
              f"{row['beta']:9.4f} {row['delta']:7.2f} {row['omega']:7.2f}")

    print()
    print("Scaling-relation deficits (measured vs closed-form prediction):")
    for n_sym in (0.0, 3.0, 12.0):
        print(f"  N = {n_sym:g}")
        for name, (measured, predicted) in scaling_deficits(n_sym, eps).items():
            flag = "OK" if abs(measured - predicted) < 1e-12 else "MISMATCH"
            print(f"    {name:<40s} {measured: .10f}  {predicted: .10f}  {flag}")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Algorithm: Bracketed Two-Loop Fixed-Point Solver with Certified Remainder.

At two loops the renormalisation-group beta function of the O(N) model is a
cubic,

    beta_N(eps, g) = -eps g + a g^2 - c g^3,   a = (N+8)/3,  c > 0,

whose non-Gaussian zero is no longer a polynomial in eps.  Dividing out the
factor g leaves the quadratic  f(x) = c x^2 - a x + eps.  The algorithm

  1. verifies the smallness condition 4 c eps <= a^2;
  2. evaluates f at the bracket endpoints eps/a and 2 eps/a, where
     f(eps/a) = c eps^2/a^2 >= 0 and f(2 eps/a) = (4 c eps - a^2) eps/a^2 <= 0,
     so a sign change is guaranteed;
  3. bisects to machine precision;
  4. returns the root together with the CERTIFIED two-sided bound

        0 <= r - (eps/a + c eps^2/a^3) <= 12 c^2 eps^3 / a^5,

     and the corresponding bound on the correction-to-scaling exponent

        |omega - (eps - c eps^2/a^2)| <= 12 c^2 eps^3 / a^4,

     where omega = -eps + 2 a r - 3 c r^2 = eps - c r^2 exactly along the
     zero locus.

Complexity: the bracket has width eps/a, so bisection to absolute accuracy
tol costs O(log2(eps/(a tol))) evaluations of a quadratic, i.e. about 60
iterations for double precision.  The certificate itself is O(1) and does
not depend on the number of iterations.

Uniformity in N: with the standard coefficient c = (3N+14)/9 one has
c <= a, and a >= 8/3 gives a^3 >= 12, hence 12 c^2 / a^5 <= 1 for every
N >= 0.  The remainder constant is therefore N-independent.
"""

from __future__ import annotations

from typing import Callable, Dict, Tuple


def bisect(f: Callable[[float], float], lo: float, hi: float,
           iters: int = 200) -> float:
    """Bisection on a bracket [lo, hi] across which f changes sign."""
    f_lo = f(lo)
    for _ in range(iters):
        mid = 0.5 * (lo + hi)
        f_mid = f(mid)
        if (f_lo > 0.0) == (f_mid > 0.0):
            lo, f_lo = mid, f_mid
        else:
            hi = mid
    return 0.5 * (lo + hi)


def two_loop_coefficient(n_sym: float) -> float:
    """Standard two-loop coefficient c(N) = (3N + 14)/9."""
    return (3.0 * n_sym + 14.0) / 9.0


def solve_two_loop_fixed_point(n_sym: float, eps: float,
                               c_two: float | None = None) -> Dict[str, float]:
    """Locate the two-loop fixed point and certify its expansion.

    Returns a dictionary with the exact root, the one- and two-loop
    predictions, the a-priori remainder bound, the observed error, the
    exponent omega and its own certified bound.
    """
    if eps <= 0.0:
        raise ValueError("eps must be positive (d < 4)")
    a = (n_sym + 8.0) / 3.0
    if a <= 0.0:
        raise ValueError("N must exceed -8")
    c = two_loop_coefficient(n_sym) if c_two is None else c_two
    if c <= 0.0:
        raise ValueError("the two-loop coefficient must be positive")
    if 4.0 * c * eps > a * a:
        raise ValueError(
            f"smallness condition 4 c eps <= a^2 fails: "
            f"{4 * c * eps:.6g} > {a * a:.6g}")

    lo, hi = eps / a, 2.0 * eps / a
    root = bisect(lambda x: c * x * x - a * x + eps, lo, hi)

    one_loop = eps / a
    two_loop = one_loop + c * eps ** 2 / a ** 3
    bound_g = 12.0 * c ** 2 * eps ** 3 / a ** 5

    omega = eps - c * root ** 2                 # exact along the zero locus
    omega_pred = eps - c * eps ** 2 / a ** 2
    bound_w = 12.0 * c ** 2 * eps ** 3 / a ** 4

    return {
        "a": a,
        "c": c,
        "root": root,
        "cubic_residual": -eps * root + a * root ** 2 - c * root ** 3,
        "one_loop": one_loop,
        "two_loop_prediction": two_loop,
        "error": root - two_loop,
        "certified_bound": bound_g,
        "omega": omega,
        "omega_prediction": omega_pred,
        "omega_error": abs(omega - omega_pred),
        "omega_bound": bound_w,
    }


def main() -> None:
    print("Two-loop O(N) fixed point with certified O(eps^3) remainder")
    print(f"{'N':>6s} {'eps':>7s} {'one-loop':>12s} {'root':>13s} "
          f"{'prediction':>13s} {'error':>11s} {'bound':>11s} {'omega':>10s}")
    for n_sym in (0.0, 1.0, 2.0, 3.0, 10.0, 50.0):
        for eps in (0.2, 0.5):
            r = solve_two_loop_fixed_point(n_sym, eps)
            assert abs(r["cubic_residual"]) < 1e-12
            assert 0.0 <= r["error"] <= r["certified_bound"] + 1e-15
            assert r["omega_error"] <= r["omega_bound"] + 1e-15
            print(f"{n_sym:6.0f} {eps:7.3f} {r['one_loop']:12.8f} "
                  f"{r['root']:13.9f} {r['two_loop_prediction']:13.9f} "
                  f"{r['error']:11.3e} {r['certified_bound']:11.3e} "
                  f"{r['omega']:10.6f}")
    print()
    print("Every error lies inside its certificate, and the certificate "
          "constant 12 c^2 / a^5 stays below 1 uniformly in N >= 0.")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""Assemble PACKAGE.json from the individual deliverable files."""

from __future__ import annotations

import json
from pathlib import Path
from typing import Any, Dict, List

ROOT = Path(__file__).resolve().parent.parent
ASSETS = ROOT / "package_assets"
LEAN_DIR = ROOT / "Catalog" / "Physics"

LEAN_FILES: List[str] = [
    "Catalog/Physics/ONModelEpsilonExpansion.lean",
    "Catalog/Physics/ONModelExponentUniformity.lean",
    "Catalog/Physics/ONModelTwoLoopFixedPoint.lean",
    "Catalog/Physics/ONModelFlowConvergence.lean",
]


def read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def lean_bundle() -> str:
    parts: List[str] = []
    for rel in LEAN_FILES:
        parts.append(f"-- ===== {rel} =====\n" + read(ROOT / rel))
    return "\n\n".join(parts)


def main() -> None:
    demo_src = read(ROOT / "demo.py")
    algo_table = read(ASSETS / "algo_exponent_table.py")
    algo_root = read(ASSETS / "algo_twoloop_root.py")
    viz_exp = read(ASSETS / "viz_exponents_vs_N.py")
    viz_flow = read(ASSETS / "viz_flow_portrait.py")
    widget = read(ASSETS / "widget_flow_explorer.html")

    package: Dict[str, Any] = {
        "title": "One Formula for Every Symmetry: Critical Exponents of the "
                 "O(N) Model, Uniformly in N",
        "domain": "Physics",
        "description":
            "The leading-order epsilon-expansion of the O(N)-symmetric phi^4 "
            "theory carried out with the symmetry index N as a free real "
            "parameter, yielding the critical exponents as explicit rational "
            "functions of N together with uniform-in-N structural theorems: a "
            "maximum of the anomalous dimension at exactly N = 4, exact "
            "closed-form deficits for every classical scaling relation, and "
            "an N-independent remainder constant at two loops.",
        "authors": ["Aristotle"],
        "date": "2026-09-03",
        "key_results": [
            "Complete classification of the one-loop fixed points: for every "
            "N different from -8 the beta function -eps g + ((N+8)/3) g^2 "
            "vanishes exactly at the Gaussian coupling 0 and at the "
            "Wilson-Fisher coupling 3 eps/(N+8), and at no other point.",
            "The critical exponents as explicit rational functions of the "
            "symmetry index: eta = (N+2)eps^2/(2(N+8)^2), nu = 1/2 + "
            "(N+2)eps/(4(N+8)), gamma = 1 + (N+2)eps/(2(N+8)), alpha = "
            "(4-N)eps/(2(N+8)), beta = 1/2 - 3eps/(2(N+8)), delta = 3 + eps, "
            "omega = eps, each reducing at N = 1 to the classical "
            "one-component values.",
            "Maximality of the anomalous dimension at four components: the "
            "coefficient (N+2)/(2(N+8)^2) is at most 1/48 for every N > -8, "
            "with equality precisely at N = 4, giving the N-free bound "
            "eta <= eps^2/48; the specific-heat exponent changes sign at the "
            "same value N = 4.",
            "Exact scaling-relation deficits: Rushbrooke's relation alpha + "
            "2 beta + gamma = 2 holds identically in (N, eps), while Widom's "
            "deficit is 3 eps^2/(N+8-3 eps), Josephson's is "
            "(N+2)eps^2/(4(N+8)) and Fisher's is nu*eta -- a consequence of "
            "the first-order exponent vector lying on an affine line in "
            "exponent space parameterised by nu.",
            "Two-loop existence with an N-independent remainder: for every "
            "N >= 0 and 0 < eps <= 4/7 the cubic beta function has a "
            "non-Gaussian zero exceeding the one-loop value and lying within "
            "eps^3 of 3 eps/(N+8) + 27 c eps^2/(N+8)^3, the constant being "
            "uniform in N because the fixed-point coupling shrinks like 1/N.",
            "Wilson-Fisher as the infrared attractor: the discrete flow "
            "g_{k+1} = g_k - h beta_N(eps, g_k) converges monotonically to "
            "3 eps/(N+8) from every start in the basin (0, g*), with the "
            "basin and the admissible step range 0 < h <= 1/eps independent "
            "of N.",
        ],
        "keywords": [
            "O(N) model",
            "epsilon-expansion",
            "Wilson-Fisher fixed point",
            "critical exponents",
            "renormalization group",
            "scaling relations",
            "anomalous dimension",
            "spherical model",
        ],
        "article": read(ROOT / "ARTICLE.md"),
        "research_paper": read(ROOT / "RESEARCH_PAPER.md"),
        "research_paper_tex": read(ROOT / "RESEARCH_PAPER.tex"),
        "demo": demo_src,
        "demos": [
            {
                "name": "Comprehensive Verification Suite for the O(N) "
                        "Critical Exponents",
                "description":
                    "A single self-contained script that reconstructs the "
                    "entire development numerically and checks every claim to "
                    "machine precision. It classifies the fixed points of the "
                    "one-loop beta function and confirms that the Gaussian "
                    "slope is -eps while the Wilson-Fisher slope is exactly "
                    "+eps for every N; verifies by finite differences that "
                    "the correction-to-scaling exponent omega equals eps "
                    "independently of the symmetry index; locates the maximum "
                    "of the anomalous-dimension coefficient numerically and "
                    "confirms it sits at N = 4 with value 1/48; evaluates all "
                    "four classical scaling relations across a range of "
                    "(N, eps) and matches each deficit against its closed "
                    "form, showing that Rushbrooke's relation is an exact "
                    "identity while Fisher's, Josephson's and Widom's carry "
                    "computable O(eps^2) defects; compares the large-N limits "
                    "with the exactly solvable spherical model and confirms "
                    "the explicit eps^2/4 and eps^2/2 error bounds; iterates "
                    "the discrete infrared flow from inside the basin (0, g*) "
                    "and confirms monotone convergence to the Wilson-Fisher "
                    "coupling for several N and step sizes; and solves the "
                    "two-loop cubic by bisection, checking that the exact "
                    "root always lies within the certified eps^3 envelope of "
                    "the predicted expansion. Requires only the Python "
                    "standard library.",
                "code": demo_src,
            }
        ],
        "algorithms": [
            {
                "name": "Wilson-Fisher Exponent Evaluation from the One-Loop "
                        "Beta Function",
                "description":
                    "Given a symmetry index N and a dimensional deficit eps "
                    "with d = 4 - eps, this routine locates the non-Gaussian "
                    "zero of the one-loop beta function by exact "
                    "factorisation rather than numerically: the polynomial "
                    "-eps g + ((N+8)/3) g^2 factors as g times a linear term, "
                    "so the only zeros are 0 and 3 eps/(N+8), and the "
                    "excluded point N = -8 is detected and reported. The "
                    "fixed-point coupling is then substituted into the "
                    "scaling functions eta(N, g) = ((N+2)/18) g^2 and "
                    "1/nu(N, g) = 2 - ((N+2)/3) g to produce the complete "
                    "first-order exponent vector. A companion routine "
                    "evaluates all four classical scaling relations and "
                    "compares each measured deficit against its closed form, "
                    "making visible the fact that Rushbrooke's relation is "
                    "exact while the three nonlinear relations are not. "
                    "Complexity: O(1) arithmetic operations per (N, eps) "
                    "pair, hence O(M) for a table over M values of N; there "
                    "is no iteration and no numerical root-finding anywhere, "
                    "so the output is exact up to floating-point rounding.",
                "pseudocode": (
                    "function WILSON_FISHER_COUPLING(N, eps):\n"
                    "    if N + 8 = 0 then\n"
                    "        raise 'excluded point: fixed point diverges'\n"
                    "    return 3 * eps / (N + 8)          # exact "
                    "factorisation of the quadratic\n"
                    "\n"
                    "function EXPONENT_VECTOR(N, eps):\n"
                    "    D    <- N + 8\n"
                    "    gs   <- WILSON_FISHER_COUPLING(N, eps)\n"
                    "    eta  <- ((N + 2) / 18) * gs^2     # two-loop "
                    "anomalous dimension at g*\n"
                    "    invnu<- 2 - ((N + 2) / 3) * gs    # one-loop 1/nu at "
                    "g*\n"
                    "    nu   <- 1/2 + (N + 2) * eps / (4 * D)\n"
                    "    gamma<- 1   + (N + 2) * eps / (2 * D)\n"
                    "    alpha<- (4 - N) * eps / (2 * D)\n"
                    "    beta <- 1/2 - 3 * eps / (2 * D)\n"
                    "    delta<- 3 + eps\n"
                    "    omega<- eps                       # = d(beta)/dg at "
                    "g*, N-independent\n"
                    "    return (gs, eta, invnu, nu, gamma, alpha, beta, "
                    "delta, omega)\n"
                    "\n"
                    "function SCALING_DEFICITS(N, eps):\n"
                    "    (gs, eta, invnu, nu, gamma, alpha, beta, delta, _) "
                    "<- EXPONENT_VECTOR(N, eps)\n"
                    "    RUSHBROOKE <- (alpha + 2*beta + gamma) - 2\n"
                    "    predict    <- 0                    # affine relation "
                    "=> exact\n"
                    "    FISHER     <- gamma - nu * (2 - eta)\n"
                    "    predict    <- nu * eta\n"
                    "    JOSEPHSON  <- (2 - alpha) - (4 - eps) * nu\n"
                    "    predict    <- (N + 2) * eps^2 / (4 * D)\n"
                    "    WIDOM      <- 1 + gamma / beta - delta\n"
                    "    predict    <- 3 * eps^2 / (N + 8 - 3 * eps)\n"
                    "    return each relation paired with its prediction\n"
                ),
                "code": algo_table,
            },
            {
                "name": "Bracketed Two-Loop Fixed-Point Solver with Certified "
                        "Remainder",
                "description":
                    "At two loops the beta function is a genuine cubic, "
                    "-eps g + a g^2 - c g^3 with a = (N+8)/3, and its "
                    "non-Gaussian zero is no longer a polynomial in eps. This "
                    "algorithm avoids formal power series entirely. Dividing "
                    "out the factor g leaves the quadratic f(x) = c x^2 - a x "
                    "+ eps, whose values at the bracket endpoints are "
                    "f(eps/a) = c eps^2/a^2 >= 0 and f(2 eps/a) = "
                    "(4 c eps - a^2) eps / a^2 <= 0 under the smallness "
                    "condition 4 c eps <= a^2, so a sign change on "
                    "[eps/a, 2 eps/a] is guaranteed and bisection converges. "
                    "The distinguishing feature is that the routine returns "
                    "not merely a root but a *certificate*: the exact "
                    "identity a^3 (r - eps/a - c eps^2/a^3) = c (a r - eps)"
                    "(a r + eps), together with the relation a r - eps = c "
                    "r^2 valid along the zero locus, yields the two-sided "
                    "bound 0 <= r - (eps/a + c eps^2/a^3) <= 12 c^2 eps^3/"
                    "a^5, and an analogous bound for the correction-to-"
                    "scaling exponent, which satisfies the exact algebraic "
                    "identity omega = eps - c r^2. Complexity: the bracket "
                    "has width eps/a, so bisection to double precision costs "
                    "roughly 60 evaluations of a quadratic, i.e. O(log(1/tol))"
                    "; the certificate itself is O(1) and independent of the "
                    "iteration count. Uniformity: with the standard "
                    "coefficient c = (3N+14)/9 one has c <= a and a >= 8/3, "
                    "so a^3 >= 12 and the remainder constant 12 c^2 / a^5 "
                    "stays below 1 for every N >= 0.",
                "pseudocode": (
                    "function SOLVE_TWO_LOOP_FIXED_POINT(N, eps, c):\n"
                    "    require eps > 0\n"
                    "    a <- (N + 8) / 3\n"
                    "    require a > 0 and c > 0\n"
                    "    if 4 * c * eps > a^2 then\n"
                    "        raise 'smallness condition violated; no "
                    "guaranteed bracket'\n"
                    "\n"
                    "    # step 1: certified bracket for the quadratic factor\n"
                    "    lo <- eps / a          # f(lo) = c eps^2 / a^2 >= 0\n"
                    "    hi <- 2 * eps / a      # f(hi) = (4 c eps - a^2) eps "
                    "/ a^2 <= 0\n"
                    "\n"
                    "    # step 2: bisect f(x) = c x^2 - a x + eps\n"
                    "    repeat until the bracket is at machine precision:\n"
                    "        mid <- (lo + hi) / 2\n"
                    "        if sign f(mid) = sign f(lo) then lo <- mid "
                    "else hi <- mid\n"
                    "    r <- (lo + hi) / 2\n"
                    "\n"
                    "    # step 3: the root of the quadratic is a zero of the "
                    "cubic\n"
                    "    assert -eps * r + a * r^2 - c * r^3 = 0   "
                    "# since the cubic is -g * f(g)\n"
                    "\n"
                    "    # step 4: certificates\n"
                    "    prediction   <- eps / a + c * eps^2 / a^3\n"
                    "    bound_g      <- 12 * c^2 * eps^3 / a^5\n"
                    "    assert 0 <= r - prediction <= bound_g\n"
                    "\n"
                    "    omega        <- eps - c * r^2    # exact along the "
                    "zero locus\n"
                    "    omega_pred   <- eps - c * eps^2 / a^2\n"
                    "    bound_w      <- 12 * c^2 * eps^3 / a^4\n"
                    "    assert |omega - omega_pred| <= bound_w\n"
                    "\n"
                    "    return (r, prediction, bound_g, omega, omega_pred, "
                    "bound_w)\n"
                ),
                "code": algo_root,
            },
        ],
        "visualizations": [
            {
                "name": "The O(N) Exponent Landscape: Extremum, Affine Line, "
                        "and Scaling Deficits",
                "description":
                    "A four-panel figure of the exponents as functions of the "
                    "symmetry index. Panel (a) plots the three leading "
                    "coefficients (N+2)/(2(N+8)^2), (N+2)/(4(N+8)) and "
                    "(4-N)/(2(N+8)) on one axis, marking the maximum of the "
                    "anomalous-dimension coefficient at N = 4 with value "
                    "1/48, the simultaneous zero of the specific-heat "
                    "coefficient at the same N = 4, and the asymptote 1/4 of "
                    "the correlation-length coefficient. Panel (b) shows the "
                    "exponents themselves at eps = 1 with the classical "
                    "universality classes N = 0, 1, 2, 3, 4 marked. Panel (c) "
                    "plots gamma against nu for three values of eps, making "
                    "visible the fact that the entire family collapses onto "
                    "the single line gamma = 2 nu -- the geometric content of "
                    "the linearity principle. Panel (d) plots the closed-form "
                    "deficits of the Widom, Josephson and Fisher relations "
                    "against N, with the identically zero Rushbrooke deficit "
                    "for contrast.",
                "code": viz_exp,
            },
            {
                "name": "Phase Portrait of the O(N) Renormalisation-Group Flow",
                "description":
                    "A three-panel dynamical picture. Panel (a) plots the "
                    "one-loop beta function for several values of N at fixed "
                    "eps, marking the Gaussian zero at the origin and the "
                    "Wilson-Fisher zero at 3 eps/(N+8), and indicating the "
                    "infrared direction; one sees directly that the "
                    "non-Gaussian zero moves towards the origin as N grows. "
                    "Panel (b) iterates the discrete infrared flow "
                    "g_{k+1} = g_k - h beta_N(eps, g_k) from three starting "
                    "points inside the basin (0, g*) for each of four values "
                    "of N, exhibiting the monotone convergence to the "
                    "Wilson-Fisher coupling that holds uniformly in N. Panel "
                    "(c) superposes the one- and two-loop beta functions at "
                    "N = 1, showing that the cubic term leaves the Gaussian "
                    "zero untouched while pushing the non-Gaussian zero to "
                    "larger coupling, in agreement with the certified "
                    "two-loop expansion.",
                "code": viz_flow,
            },
        ],
        "interactive_demos": [
            {
                "title": "The O(N) Critical Point Explorer",
                "description":
                    "A single, deeply interactive laboratory for the whole "
                    "development. Two sliders control the symmetry index N "
                    "and the dimensional deficit eps, with one-click presets "
                    "for the polymer (N = 0), Ising (N = 1), XY (N = 2), "
                    "Heisenberg (N = 3), the extremum (N = 4) and the "
                    "approach to the spherical limit. Everything on the page "
                    "recomputes live from the single quadratic beta function. "
                    "A first canvas draws the beta function with both fixed "
                    "points marked and reports the slopes, letting the reader "
                    "discover for themselves that the Gaussian slope is -eps "
                    "and the Wilson-Fisher slope is exactly +eps regardless "
                    "of N. A second canvas iterates the discrete infrared "
                    "flow from three starting couplings, all climbing "
                    "monotonically to the same limit. A third canvas plots "
                    "the anomalous-dimension coefficient across N with the "
                    "current value tracked as a moving dot, so the maximum at "
                    "N = 4 is felt rather than merely asserted. Three live "
                    "tables show the exponent values against reference "
                    "three-dimensional estimates, the four scaling-relation "
                    "deficits against their closed forms -- with the "
                    "Rushbrooke row visibly pinned to zero while the others "
                    "move -- and the large-N comparison against the exactly "
                    "solvable spherical model with its explicit error bounds. "
                    "Collapsible sections carry the proofs: why the slope at "
                    "the fixed point is exactly eps, where the extremum at "
                    "N = 4 comes from, and the linearity principle that "
                    "explains why exactly one scaling relation survives "
                    "truncation. A guided-tour button sweeps N from 0 to 30 "
                    "so the reader can watch the whole family deform.",
                "html": widget,
            }
        ],
        "interactive_layout": read(ASSETS / "interactive_layout.md"),
        "lean_proofs": lean_bundle(),
        "future_directions": read(ASSETS / "future_directions.md"),
        "modules": {"demo": demo_src},
        "lean_files": LEAN_FILES,
    }

    out = ROOT / "PACKAGE.json"
    out.write_text(json.dumps(package, indent=2, ensure_ascii=False) + "\n",
                   encoding="utf-8")
    print(f"wrote {out} ({out.stat().st_size} bytes)")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: The O(N) Exponent Landscape as a Function of the Symmetry Index.

Four panels:

  (a) the leading coefficients eta_2(N) = (N+2)/(2(N+8)^2),
      nu_1(N) = (N+2)/(4(N+8)) and alpha_1(N) = (4-N)/(2(N+8)),
      with the extremum of eta_2 at N = 4 (value 1/48) and the zero of
      alpha_1 at N = 4 marked;
  (b) the exponents themselves at eps = 1, with the classical universality
      classes N = 0, 1, 2, 3 highlighted;
  (c) the affine line in exponent space: gamma versus nu, showing that the
      whole family lies on gamma = 2 nu;
  (d) the closed-form deficits of the Widom, Josephson and Fisher relations,
      confirming that the only exactly satisfied relation is Rushbrooke.

Produces `on_model_exponents.png`.  Requires numpy and matplotlib.
"""

from __future__ import annotations

from typing import Tuple

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np


def eta_coeff(n: np.ndarray) -> np.ndarray:
    return (n + 2.0) / (2.0 * (n + 8.0) ** 2)


def nu_coeff(n: np.ndarray) -> np.ndarray:
    return (n + 2.0) / (4.0 * (n + 8.0))


def alpha_coeff(n: np.ndarray) -> np.ndarray:
    return (4.0 - n) / (2.0 * (n + 8.0))


def exponents(n: np.ndarray, eps: float) -> Tuple[np.ndarray, ...]:
    eta = (n + 2.0) * eps ** 2 / (2.0 * (n + 8.0) ** 2)
    nu = 0.5 + (n + 2.0) * eps / (4.0 * (n + 8.0))
    gamma = 1.0 + (n + 2.0) * eps / (2.0 * (n + 8.0))
    alpha = (4.0 - n) * eps / (2.0 * (n + 8.0))
    beta = 0.5 - 3.0 * eps / (2.0 * (n + 8.0))
    return eta, nu, gamma, alpha, beta


def main() -> None:
    eps = 1.0
    n_grid = np.linspace(0.0, 30.0, 2000)
    classes = {0: "SAW", 1: "Ising", 2: "XY", 3: "Heisenberg", 4: "O(4)"}

    fig, axes = plt.subplots(2, 2, figsize=(13.5, 9.5))
    fig.suptitle(
        r"The $O(N)$ critical exponents at first order in $\varepsilon = 4-d$",
        fontsize=15, weight="bold")

    # ---- (a) leading coefficients ----------------------------------------
    ax = axes[0, 0]
    scale = 8.0  # eta_2 is an order of magnitude smaller than the others
    ax.plot(n_grid, scale * eta_coeff(n_grid), lw=2.2, color="#c0392b",
            label=rf"${scale:.0f}\,\eta_2(N)$, "
                  r"$\eta_2=\frac{N+2}{2(N+8)^2}$")
    ax.plot(n_grid, nu_coeff(n_grid), lw=2.2, color="#2980b9",
            label=r"$\nu_1(N)=\frac{N+2}{4(N+8)}$")
    ax.plot(n_grid, alpha_coeff(n_grid), lw=2.2, color="#27ae60",
            label=r"$\alpha_1(N)=\frac{4-N}{2(N+8)}$")
    ax.axhline(0.0, color="0.6", lw=0.8)
    ax.axhline(scale / 48.0, color="#c0392b", ls=":", lw=1.2)
    ax.axhline(0.25, color="#2980b9", ls=":", lw=1.2)
    ax.axvline(4.0, color="0.35", ls="--", lw=1.4)
    ax.plot([4.0], [scale / 48.0], "o", ms=8, color="#c0392b", zorder=5)
    ax.annotate(r"max $\eta_2 = 1/48$ at $N=4$", xy=(4.0, scale / 48),
                xytext=(6.8, 0.045), fontsize=10,
                arrowprops=dict(arrowstyle="->", color="0.3"))
    ax.annotate(r"$\alpha_1 = 0$ at $N=4$", xy=(4.0, 0.0),
                xytext=(11.0, -0.28), fontsize=10,
                arrowprops=dict(arrowstyle="->", color="0.3"))
    ax.annotate(r"$\nu_1 \to 1/4$ (spherical)", xy=(28.0, 0.243),
                xytext=(15.5, -0.10), fontsize=10,
                arrowprops=dict(arrowstyle="->", color="0.3"))
    ax.set_xlabel(r"symmetry index $N$")
    ax.set_ylabel("leading coefficient")
    ax.set_title("(a)  Two features at the same place: $N = 4$", loc="left")
    ax.legend(loc="lower left", fontsize=9)
    ax.grid(alpha=0.25)

    # ---- (b) exponents at eps = 1 ----------------------------------------
    ax = axes[0, 1]
    eta, nu, gamma, alpha, beta = exponents(n_grid, eps)
    ax.plot(n_grid, nu, lw=2.2, color="#2980b9", label=r"$\nu$")
    ax.plot(n_grid, gamma, lw=2.2, color="#8e44ad", label=r"$\gamma$")
    ax.plot(n_grid, alpha, lw=2.2, color="#27ae60", label=r"$\alpha$")
    ax.plot(n_grid, beta, lw=2.2, color="#d35400", label=r"$\beta$")
    ax.plot(n_grid, 20.0 * eta, lw=1.8, color="#c0392b", ls="-.",
            label=r"$20\,\eta$  (scaled)")
    ax.axhline(0.0, color="0.6", lw=0.8)
    for n_val, name in classes.items():
        ax.axvline(n_val, color="0.85", lw=1.0, zorder=0)
        ax.text(n_val, 1.53, name, rotation=90, fontsize=8,
                ha="right", va="top", color="0.4")
    ax.set_xlim(0, 20)
    ax.set_ylim(-0.6, 1.6)
    ax.set_xlabel(r"symmetry index $N$")
    ax.set_ylabel("exponent value")
    ax.set_title(r"(b)  Exponents at $\varepsilon = 1$ ($d = 3$)", loc="left")
    ax.legend(loc="upper right", ncol=2, fontsize=9)
    ax.grid(alpha=0.25)

    # ---- (c) the affine line gamma = 2 nu --------------------------------
    ax = axes[1, 0]
    for e_val, colour in ((0.25, "#95a5a6"), (0.5, "#5dade2"), (1.0, "#1f618d")):
        _, nu_e, gamma_e, _, _ = exponents(n_grid, e_val)
        ax.plot(nu_e, gamma_e, lw=2.4, color=colour,
                label=rf"$\varepsilon = {e_val}$")
    nu_line = np.linspace(0.5, 0.78, 50)
    ax.plot(nu_line, 2.0 * nu_line, "k--", lw=1.2, label=r"$\gamma = 2\nu$")
    ax.plot([0.5], [1.0], "ko", ms=7)
    ax.annotate("mean field", xy=(0.5, 1.0), xytext=(0.53, 1.06), fontsize=10,
                arrowprops=dict(arrowstyle="->", color="0.3"))
    ax.set_xlabel(r"$\nu$")
    ax.set_ylabel(r"$\gamma$")
    ax.set_title(r"(c)  The whole family lies on one line: $\gamma = 2\nu$",
                 loc="left")
    ax.legend(fontsize=10)
    ax.grid(alpha=0.25)

    # ---- (d) scaling-relation deficits -----------------------------------
    ax = axes[1, 1]
    widom = 3.0 * eps ** 2 / (n_grid + 8.0 - 3.0 * eps)
    joseph = (n_grid + 2.0) * eps ** 2 / (4.0 * (n_grid + 8.0))
    fisher = nu * eta
    ax.plot(n_grid, widom, lw=2.2, color="#c0392b",
            label=r"Widom: $\frac{3\varepsilon^2}{N+8-3\varepsilon}$")
    ax.plot(n_grid, joseph, lw=2.2, color="#2980b9",
            label=r"Josephson: $\frac{(N+2)\varepsilon^2}{4(N+8)}$")
    ax.plot(n_grid, fisher, lw=2.2, color="#8e44ad",
            label=r"Fisher: $\nu\eta$")
    ax.plot(n_grid, np.zeros_like(n_grid), lw=3.0, color="#27ae60",
            label=r"Rushbrooke: $0$ (exact)")
    ax.set_xlabel(r"symmetry index $N$")
    ax.set_ylabel(r"deficit at $\varepsilon = 1$")
    ax.set_title("(d)  Linear relation exact, nonlinear ones deficient",
                 loc="left")
    ax.legend(fontsize=9)
    ax.grid(alpha=0.25)

    fig.tight_layout(rect=(0, 0, 1, 0.96))
    fig.savefig("on_model_exponents.png", dpi=150)
    print("wrote on_model_exponents.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Phase Portrait of the O(N) Renormalisation-Group Flow.

Three panels:

  (a) the one-loop beta function beta_N(eps, g) = -eps g + ((N+8)/3) g^2 for
      several N at fixed eps, with the Gaussian zero at g = 0 and the
      Wilson-Fisher zero at g* = 3 eps/(N+8) marked, and arrows indicating
      the infrared direction -beta;

  (b) trajectories of the discrete infrared flow
      g_{k+1} = g_k - h beta_N(eps, g_k) from several starting points inside
      the basin (0, g*), showing monotone convergence to g* for every N;

  (c) the one- and two-loop beta functions superposed, showing that the cubic
      term pushes the non-Gaussian zero to larger coupling while leaving the
      Gaussian zero untouched.

Produces `on_model_flow.png`.  Requires numpy and matplotlib.
"""

from __future__ import annotations

from typing import List

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np


def beta_one_loop(n: float, eps: float, g: np.ndarray) -> np.ndarray:
    return -eps * g + ((n + 8.0) / 3.0) * g ** 2


def beta_two_loop(n: float, c: float, eps: float, g: np.ndarray) -> np.ndarray:
    return beta_one_loop(n, eps, g) - c * g ** 3


def flow(n: float, eps: float, h: float, g0: float, steps: int) -> List[float]:
    seq = [g0]
    g = g0
    for _ in range(steps):
        g = g - h * (-eps * g + ((n + 8.0) / 3.0) * g * g)
        seq.append(g)
    return seq


def main() -> None:
    eps = 1.0
    fig, axes = plt.subplots(1, 3, figsize=(16.5, 5.8))
    fig.suptitle(
        r"The $O(N)$ renormalisation-group flow at $\varepsilon = 1$",
        fontsize=15, weight="bold")

    # ---- (a) beta functions ----------------------------------------------
    ax = axes[0]
    colours = {0: "#c0392b", 1: "#e67e22", 3: "#27ae60", 10: "#2980b9"}
    g = np.linspace(-0.05, 0.45, 600)
    for n, col in colours.items():
        ax.plot(g, beta_one_loop(n, eps, g), lw=2.1, color=col,
                label=rf"$N = {n}$")
        g_star = 3.0 * eps / (n + 8.0)
        ax.plot([g_star], [0.0], "o", ms=7, color=col)
    ax.axhline(0.0, color="0.4", lw=1.0)
    ax.axvline(0.0, color="0.75", lw=0.8)
    ax.annotate("", xy=(0.06, -0.028), xytext=(0.015, -0.028),
                arrowprops=dict(arrowstyle="->", lw=1.8, color="0.25"))
    ax.text(0.075, -0.032, "infrared flow", fontsize=9, color="0.25")
    ax.set_xlabel(r"coupling $g$")
    ax.set_ylabel(r"$\beta_N(\varepsilon, g)$")
    ax.set_title(r"(a)  $\beta_N = -\varepsilon g + \frac{N+8}{3}g^2$"
                 "\n"
                 r"zeros at $0$ and $g^\ast=\frac{3\varepsilon}{N+8}$",
                 loc="left", fontsize=11)
    ax.legend(fontsize=9)
    ax.grid(alpha=0.25)

    # ---- (b) discrete flow trajectories ----------------------------------
    ax = axes[1]
    step = 0.5
    for n, col in colours.items():
        g_star = 3.0 * eps / (n + 8.0)
        ax.axhline(g_star, color=col, ls=":", lw=1.3)
        for frac in (0.03, 0.35, 0.85):
            seq = flow(n, eps, step, frac * g_star, 40)
            ax.plot(range(len(seq)), seq, lw=1.7, color=col, alpha=0.85)
        ax.text(26.0, g_star + 0.004, rf"$g^\ast(N={n})$", color=col,
                fontsize=9, va="bottom")
    ax.set_xlim(0, 40)
    ax.set_xlabel(r"coarse-graining step $k$")
    ax.set_ylabel(r"$g_k$")
    ax.set_title(r"(b)  $g_{k+1}=g_k-h\,\beta_N(\varepsilon,g_k)$, $h=0.5$"
                 "\n"
                 r"monotone convergence from the basin $(0,g^\ast)$",
                 loc="left", fontsize=11)
    ax.grid(alpha=0.25)

    # ---- (c) one loop vs two loops ---------------------------------------
    ax = axes[2]
    n = 1.0
    c = (3.0 * n + 14.0) / 9.0
    eps_c = 0.5
    g = np.linspace(-0.02, 0.30, 700)
    ax.plot(g, beta_one_loop(n, eps_c, g), lw=2.2, color="#2980b9",
            label="one loop")
    ax.plot(g, beta_two_loop(n, c, eps_c, g), lw=2.2, color="#c0392b",
            label="two loops")
    ax.axhline(0.0, color="0.4", lw=1.0)
    g1 = 3.0 * eps_c / (n + 8.0)
    a = (n + 8.0) / 3.0
    # exact non-Gaussian zero of the cubic, by the quadratic formula
    g2 = (a - np.sqrt(a * a - 4.0 * c * eps_c)) / (2.0 * c)
    ax.plot([g1], [0.0], "o", ms=8, color="#2980b9")
    ax.plot([g2], [0.0], "o", ms=8, color="#c0392b")
    ax.annotate(r"$g^\ast_{1\ell}$", xy=(g1, 0), xytext=(g1 - 0.035, 0.010),
                fontsize=11, color="#2980b9")
    ax.annotate(r"$g^\ast_{2\ell}$", xy=(g2, 0), xytext=(g2 + 0.008, -0.014),
                fontsize=11, color="#c0392b")
    ax.set_xlabel(r"coupling $g$")
    ax.set_ylabel(r"$\beta$")
    ax.set_title(r"(c)  $N=1$, $\varepsilon=0.5$"
                 "\n"
                 r"the cubic term moves the fixed point up",
                 loc="left", fontsize=11)
    ax.legend(fontsize=10)
    ax.grid(alpha=0.25)

    fig.tight_layout(rect=(0, 0, 1, 0.94))
    fig.savefig("on_model_flow.png", dpi=150)
    print("wrote on_model_flow.png")


if __name__ == "__main__":
    main()
