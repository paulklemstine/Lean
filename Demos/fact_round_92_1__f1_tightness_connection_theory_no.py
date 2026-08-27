"""
demo.py — Numerical demonstration of the slack factor of the scan speed-up
inequality.

Self-contained: standard library only (math, itertools, random). Every helper
is inlined below.

Setting
-------
A window is split into M cells 0, 1, ..., M-1. The target sits in cell i with
prior probability p[i]. A *policy* is a permutation sigma of the cells; it
probes cell i at rank sigma(i) + 1, so its expected probe count is

    cost(p, sigma) = sum_i (sigma(i) + 1) * p[i].

Three costs organise the theory:

    c_asc  = sum_i (i + 1) * p[i]        (ascending / left-to-right scan)
    c_desc = sum_i (M - i) * p[i]        (descending / right-to-left scan)
    C0     = (M + 1) / 2                 (flat-profile baseline)

Conservation identity:  c_asc + c_desc = M + 1 = 2 * C0.

Shape parameters and the master bound (coverage parameter qhat = 1):

    Lam   = c_asc / c_desc      Theta = c_asc / C0      X = C0 / c_asc
    S_asc = c_desc / c_asc = 1 / Lam    bound = 1 / (Lam * Theta)

Identity chain:  X = 1/Theta = (1 + Lam) / (2 * Lam)  and  bound = X * S_asc.

The demonstrations below verify, numerically:
  1. the conservation identity and the identity chain;
  2. optimality and uniqueness of the ascending scan (exhaustive audit);
  3. strict unattainability of the bound on front-loaded non-flat profiles;
  4. sharpness of the bound over the class of priors (two-cell family);
  5. the optimal L1 dispersion strengthening;
  6. the mean-position fibration and the exact reachable slack range;
  7. the constrained (tail-mass) slack polytope;
  8. grid refinement raising the measured slack;
  9. the harmonic profile forcing slack for every window ratio;
 10. the measured numbers of the reported positional profile;
 11. non-identifiability of the coverage parameter (the circularity catch).
"""

from __future__ import annotations

import itertools
import math
import random
from typing import Callable, Dict, List, Sequence, Tuple

TOL: float = 1e-12


# ----------------------------------------------------------------------------
# Core quantities
# ----------------------------------------------------------------------------

def scan_cost(p: Sequence[float]) -> float:
    """Ascending (left-to-right) expected probe count: sum_i (i+1) p_i."""
    return sum((i + 1) * pi for i, pi in enumerate(p))


def rev_cost(p: Sequence[float]) -> float:
    """Descending (right-to-left) expected probe count: sum_i (M-i) p_i."""
    m = len(p)
    return sum((m - i) * pi for i, pi in enumerate(p))


def base_cost(m: int) -> float:
    """Flat-profile baseline C0 = (M+1)/2."""
    return (m + 1) / 2.0


def policy_cost(p: Sequence[float], sigma: Sequence[int]) -> float:
    """Expected probe count of the policy probing cell i at rank sigma[i]+1."""
    return sum((sigma[i] + 1) * p[i] for i in range(len(p)))


def mean_pos(p: Sequence[float]) -> float:
    """Mean normalised probe position E_x = sum_i ((i + 1/2)/M) p_i."""
    m = len(p)
    return sum(((i + 0.5) / m) * pi for i, pi in enumerate(p))


def parameters(p: Sequence[float]) -> Dict[str, float]:
    """All shape parameters, speed-ups and the master bound for a profile."""
    m = len(p)
    c_asc = scan_cost(p)
    c_desc = rev_cost(p)
    c0 = base_cost(m)
    lam = c_asc / c_desc
    theta = c_asc / c0
    return {
        "M": float(m),
        "c_asc": c_asc,
        "c_desc": c_desc,
        "C0": c0,
        "Lam": lam,
        "Theta": theta,
        "X": c0 / c_asc,
        "S_asc": c_desc / c_asc,
        "bound": 1.0 / (lam * theta),
        "E_x": mean_pos(p),
    }


def gap_of_lam(lam: float) -> float:
    """The slack factor as a function of Lambda alone: X = (1+Lam)/(2 Lam)."""
    return (1.0 + lam) / (2.0 * lam)


def flat_dist(p: Sequence[float]) -> float:
    """L1 distance of the profile to the flat profile: sum_i |p_i - 1/M|."""
    m = len(p)
    return sum(abs(pi - 1.0 / m) for pi in p)


def edge_mass(p: Sequence[float], k: int) -> float:
    """Mass on the cells of index >= k."""
    return sum(p[i] for i in range(k, len(p)))


# ----------------------------------------------------------------------------
# Profile constructors
# ----------------------------------------------------------------------------

def flat_profile(m: int) -> List[float]:
    """The uniform profile on M cells."""
    return [1.0 / m] * m


def two_cell(delta: float) -> List[float]:
    """The two-cell family (1/2 + delta, 1/2 - delta)."""
    return [0.5 + delta, 0.5 - delta]


def linear_profile(m: int) -> List[float]:
    """A front-loaded linearly decreasing profile on M cells."""
    raw = [float(m - i) for i in range(m)]
    total = sum(raw)
    return [x / total for x in raw]


def harmonic_profile(m: int, r: float) -> List[float]:
    """Cell-averaged harmonic (1/x) profile on a window of dynamic range r > 1.

    The continuum CDF is F_r(u) = log(1 + (r-1) u) / log r on [0, 1]; the cell
    masses are its increments over the M equal subintervals.
    """
    def cdf(u: float) -> float:
        return math.log1p((r - 1.0) * u) / math.log(r)

    return [cdf((i + 1) / m) - cdf(i / m) for i in range(m)]


def point_mass(m: int, j: int) -> List[float]:
    """The point mass on cell j."""
    p = [0.0] * m
    p[j] = 1.0
    return p


def pair_profile(m: int, a: int, b: int, mass: float) -> List[float]:
    """(1 - mass) on cell a and mass on cell b."""
    p = [0.0] * m
    p[a] += 1.0 - mass
    p[b] += mass
    return p


# ----------------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------------

def demo_conservation_and_identity_chain() -> None:
    """1. Conservation identity and the exact identity chain."""
    print("=" * 74)
    print("1. CONSERVATION IDENTITY AND IDENTITY CHAIN")
    print("=" * 74)
    rng = random.Random(20260827)
    print(f"{'M':>4} {'c_asc+c_desc':>13} {'M+1':>7} {'X':>10} "
          f"{'1/Theta':>10} {'(1+L)/2L':>10} {'bound':>10} {'X*S_asc':>10}")
    for m in (2, 3, 5, 8, 13, 27):
        raw = [rng.random() for _ in range(m)]
        total = sum(raw)
        p = [x / total for x in raw]
        q = parameters(p)
        print(f"{m:>4} {q['c_asc'] + q['c_desc']:>13.9f} {m + 1:>7} "
              f"{q['X']:>10.6f} {1.0 / q['Theta']:>10.6f} "
              f"{gap_of_lam(q['Lam']):>10.6f} {q['bound']:>10.6f} "
              f"{q['X'] * q['S_asc']:>10.6f}")
        assert abs(q["c_asc"] + q["c_desc"] - (m + 1)) < TOL
        assert abs(q["X"] - 1.0 / q["Theta"]) < TOL
        assert abs(q["X"] - gap_of_lam(q["Lam"])) < TOL
        assert abs(q["bound"] - q["X"] * q["S_asc"]) < TOL
    print("\n  All four identities hold to machine precision, for arbitrary")
    print("  (not necessarily monotone) profiles: they need only total mass 1.\n")


def demo_policy_audit(m: int = 6) -> None:
    """2-3. Exhaustive policy audit: optimality, uniqueness, unattainability."""
    print("=" * 74)
    print(f"2-3. EXHAUSTIVE POLICY AUDIT OVER ALL {math.factorial(m)} POLICIES (M={m})")
    print("=" * 74)
    p = linear_profile(m)
    q = parameters(p)
    best_cost = math.inf
    best_sigma: Tuple[int, ...] = tuple()
    n_optimal = 0
    max_speedup = -math.inf
    for sigma in itertools.permutations(range(m)):
        c = policy_cost(p, sigma)
        if c < best_cost - TOL:
            best_cost, best_sigma, n_optimal = c, sigma, 1
        elif abs(c - best_cost) <= TOL:
            n_optimal += 1
        max_speedup = max(max_speedup, q["c_desc"] / c)
    print(f"  profile            : {[round(x, 5) for x in p]}")
    print(f"  minimising policy  : {best_sigma}  (identity = ascending scan)")
    print(f"  number of minimisers: {n_optimal}  (uniqueness of the optimum)")
    print(f"  min cost           : {best_cost:.9f}   c_asc = {q['c_asc']:.9f}")
    print(f"  best speed-up S_max: {max_speedup:.9f}   S_asc = {q['S_asc']:.9f}")
    print(f"  master bound       : {q['bound']:.9f}")
    print(f"  slack factor X     : {q['X']:.9f}  > 1")
    print(f"  S_max * X          : {max_speedup * q['X']:.9f}  = bound")
    assert best_sigma == tuple(range(m)) and n_optimal == 1
    assert max_speedup < q["bound"] - 1e-9
    assert abs(max_speedup * q["X"] - q["bound"]) < TOL
    print("\n  No policy attains the bound: every speed-up falls short by the")
    print("  factor X, and X > 1 because the profile is front-loaded and not flat.\n")


def demo_sharpness_over_class() -> None:
    """4. Sharpness over the prior class via the two-cell family."""
    print("=" * 74)
    print("4. SHARPNESS OVER THE PRIOR CLASS (TWO-CELL FAMILY)")
    print("=" * 74)
    print(f"{'delta':>10} {'c_asc':>10} {'X (measured)':>14} "
          f"{'(3/2)/(3/2-d)':>15} {'X > 1?':>8}")
    for delta in (0.25, 0.1, 0.01, 1e-3, 1e-5, 1e-8):
        p = two_cell(delta)
        q = parameters(p)
        closed = 1.5 / (1.5 - delta)
        print(f"{delta:>10.0e} {q['c_asc']:>10.6f} {q['X']:>14.10f} "
              f"{closed:>15.10f} {str(q['X'] > 1.0):>8}")
        assert abs(q["X"] - closed) < 1e-12
        assert q["X"] > 1.0
    print("\n  X -> 1 as delta -> 0, yet X > 1 for every admissible delta > 0:")
    print("  the bound is sharp over the class and attained on no member of it.\n")


def demo_dispersion() -> None:
    """5. The optimal L1 dispersion strengthening."""
    print("=" * 74)
    print("5. QUANTITATIVE DISPERSION STRENGTHENING")
    print("=" * 74)
    print("  Claim: X >= 1 + ||p-flat||_1 / (2 c_asc) >= 1 + ||p-flat||_1 / (2M),")
    print("  with equality in the sharper form on two-cell profiles.\n")
    print(f"{'profile':>28} {'||p-flat||_1':>13} {'1+D/2M':>10} "
          f"{'1+D/2c_asc':>12} {'X':>10}")
    profiles: List[Tuple[str, List[float]]] = [
        ("two-cell (3/4, 1/4)", [0.75, 0.25]),
        ("two-cell (1/2+.25,.25)", two_cell(0.25)),
        ("linear M=4", linear_profile(4)),
        ("linear M=27", linear_profile(27)),
        ("harmonic M=27, r=100", harmonic_profile(27, 100.0)),
    ]
    for name, p in profiles:
        m = len(p)
        q = parameters(p)
        d = flat_dist(p)
        weak = 1.0 + d / (2.0 * m)
        strong = 1.0 + d / (2.0 * q["c_asc"])
        print(f"{name:>28} {d:>13.6f} {weak:>10.6f} {strong:>12.6f} {q['X']:>10.6f}")
        assert weak <= strong + 1e-12 <= q["X"] + 1e-12
    exact = parameters(two_cell(0.25))
    d = flat_dist(two_cell(0.25))
    print(f"\n  Two-cell exactness: 1 + D/(2 c_asc) = "
          f"{1.0 + d / (2.0 * exact['c_asc']):.12f} = X = {exact['X']:.12f}")
    print("  Hence no constant c > 1 is admissible in 1 + c*D/(2 c_asc) <= X.\n")


def demo_fibration_and_range() -> None:
    """6. The mean-position fibration and the exact reachable slack range."""
    print("=" * 74)
    print("6. MEAN-POSITION FIBRATION AND THE EXACT SLACK RANGE")
    print("=" * 74)
    m = 8
    # Two very differently shaped profiles with the same mean position.
    p1 = [0.30, 0.20, 0.10, 0.05, 0.05, 0.10, 0.10, 0.10]
    target = mean_pos(p1)
    # Build a two-cell profile with the same mean position.
    lo, hi = (0.5) / m, (m - 0.5) / m
    w = (target - lo) / (hi - lo)
    p2 = pair_profile(m, 0, m - 1, w)
    print(f"  profile A       : {p1}")
    print(f"  profile B       : {[round(x, 6) for x in p2]}")
    print(f"  E_x(A) = {mean_pos(p1):.12f}   E_x(B) = {mean_pos(p2):.12f}")
    print(f"  X(A)   = {parameters(p1)['X']:.12f}   X(B)   = "
          f"{parameters(p2)['X']:.12f}")
    assert abs(parameters(p1)["X"] - parameters(p2)["X"]) < 1e-10
    print("\n  Equal mean position => equal slack, whatever the shape.\n")
    print(f"{'M':>4} {'X(delta_last)':>15} {'(M+1)/(2M)':>12} "
          f"{'X(delta_first)':>16} {'(M+1)/2':>10}")
    for mm in (2, 4, 8, 27):
        lo_p = point_mass(mm, mm - 1)
        hi_p = point_mass(mm, 0)
        print(f"{mm:>4} {parameters(lo_p)['X']:>15.9f} "
              f"{(mm + 1) / (2.0 * mm):>12.9f} "
              f"{parameters(hi_p)['X']:>16.9f} {(mm + 1) / 2.0:>10.9f}")
        assert abs(parameters(lo_p)["X"] - (mm + 1) / (2.0 * mm)) < TOL
        assert abs(parameters(hi_p)["X"] - (mm + 1) / 2.0) < TOL
    print("\n  Both endpoints of X in [(M+1)/(2M), (M+1)/2] are attained by")
    print("  point masses, so the range cannot be shrunk.\n")


def demo_constrained_polytope(m: int = 27, k: int = 9) -> None:
    """7. The constrained (tail-mass) slack polytope."""
    print("=" * 74)
    print(f"7. CONSTRAINED SLACK POLYTOPE (M={m}, cut K={k})")
    print("=" * 74)
    print("  Constraint: mass on cells of index >= K is at least m.")
    print("  Theory: E_x >= (1/2 + K m)/M  and  X <= (M+1)/(2 K m + 2), sharp.\n")
    print(f"{'m':>8} {'predicted max X':>17} {'X(extremal pair)':>18} "
          f"{'random-search max':>18}")
    rng = random.Random(11)
    for mass in (0.0, 0.05, 0.2, 0.5, 0.9):
        predicted = (m + 1) / (2.0 * k * mass + 2.0)
        extremal = parameters(pair_profile(m, 0, k, mass))["X"]
        best = 0.0
        for _ in range(20000):
            raw = [rng.random() ** 6 for _ in range(m)]
            tot = sum(raw)
            cand = [x / tot for x in raw]
            if edge_mass(cand, k) >= mass:
                best = max(best, parameters(cand)["X"])
        print(f"{mass:>8.2f} {predicted:>17.9f} {extremal:>18.9f} {best:>18.9f}")
        assert abs(extremal - predicted) < 1e-9
        assert best <= predicted + 1e-9
    print("\n  The two-cell profile (1-m on cell 0, m on cell K) attains the")
    print("  bound exactly; random admissible profiles never exceed it.\n")


def demo_refinement() -> None:
    """8. Grid refinement strictly raises the measured slack."""
    print("=" * 74)
    print("8. GRID REFINEMENT RAISES THE MEASURED SLACK")
    print("=" * 74)

    def coarsen(p: Sequence[float]) -> List[float]:
        return [p[2 * j] + p[2 * j + 1] for j in range(len(p) // 2)]

    fine = [0.4, 0.3, 0.2, 0.1]
    coarse = coarsen(fine)
    shift = sum(fine[2 * j] - fine[2 * j + 1] for j in range(len(coarse))) / (
        4.0 * len(coarse))
    print(f"  fine   profile {fine}: E_x = {mean_pos(fine):.9f}, "
          f"X = {parameters(fine)['X']:.9f}   (= 5/4)")
    print(f"  coarse profile {[round(x, 4) for x in coarse]}      : "
          f"E_x = {mean_pos(coarse):.9f}, X = {parameters(coarse)['X']:.9f}"
          f"   (= 15/13)")
    print(f"  predicted mean shift  = {shift:.12f}")
    print(f"  observed  mean shift  = {mean_pos(coarse) - mean_pos(fine):.12f}")
    assert abs(mean_pos(coarse) - mean_pos(fine) - shift) < TOL
    assert parameters(coarse)["X"] < parameters(fine)["X"]
    print("\n  Grid monotonicity at fixed mean position E:")
    e = 0.4336
    print(f"{'M':>6} {'X_M(E)':>14} {'continuum 1/(2E)':>18}")
    prev = -math.inf
    for mm in (2, 4, 8, 27, 100, 1000, 100000):
        xm = (mm + 1) / (2.0 * mm * e + 1.0)
        print(f"{mm:>6} {xm:>14.9f} {1.0 / (2.0 * e):>18.9f}")
        assert xm > prev and xm < 1.0 / (2.0 * e)
        prev = xm
    print("\n  Every finite-grid slack estimate is a strict LOWER bound for the")
    print("  continuum slack: the reported value can be read one-sidedly.\n")


def demo_harmonic() -> None:
    """9. The harmonic profile forces slack for every window ratio."""
    print("=" * 74)
    print("9. THE HARMONIC PROFILE FORCES SLACK")
    print("=" * 74)

    def harm_mean(r: float) -> float:
        return 1.0 / math.log(r) - 1.0 / (r - 1.0)

    print("  E(r) = 1/log r - 1/(r-1);  E(r) < 1/2  <=>  log r > 2(r-1)/(r+1).\n")
    print(f"{'r':>12} {'E(r)':>12} {'log r':>12} {'2(r-1)/(r+1)':>14} "
          f"{'Lam=E/(1-E)':>13} {'X=1/(2E)':>11}")
    for r in (1.001, 1.1, 2.0, 10.0, 100.0, 1e4, 1e8):
        e = harm_mean(r)
        lam = e / (1.0 - e)
        print(f"{r:>12.4g} {e:>12.8f} {math.log(r):>12.8f} "
              f"{2 * (r - 1) / (r + 1):>14.8f} {lam:>13.8f} "
              f"{1.0 / (2.0 * e):>11.6f}")
        assert 0.0 < e < 0.5
        assert math.log(r) > 2 * (r - 1) / (r + 1)
        assert abs(1.0 / (2.0 * e) - gap_of_lam(lam)) < 1e-9
    print("\n  For every window ratio r > 1 the slack exceeds 1, and it diverges")
    print("  as r -> infinity: wider windows make the bound less informative.\n")


def demo_measured_profile() -> None:
    """10. The measured numbers of the reported positional profile."""
    print("=" * 74)
    print("10. THE MEASURED POSITIONAL PROFILE")
    print("=" * 74)
    lam = 0.765671
    theta = 2.0 * lam / (1.0 + lam)
    x = gap_of_lam(lam)
    s_asc = 1.0 / lam
    bound = 1.0 / (lam * theta)
    e_x = lam / (1.0 + lam)
    print(f"  Lambda (measured)          = {lam:.6f}")
    print(f"  mean position E = L/(1+L)  = {e_x:.6f}   (< 1/2)")
    print(f"  Theta = 2L/(1+L)           = {theta:.6f}   (booked ~ 0.867)")
    print(f"  slack X = (1+L)/(2L)       = {x:.6f}   (booked   1.15302)")
    print(f"  best realizable S = 1/L    = {s_asc:.6f}   (booked ~ 1.306)")
    print(f"  master bound = 1/(L*Theta) = {bound:.6f}   (booked ~ 1.506)")
    print(f"  bound / S_asc              = {bound / s_asc:.6f}   (= X)")
    print(f"  check X = 1/(2E)           = {1.0 / (2.0 * e_x):.6f}")
    assert abs(bound - x * s_asc) < TOL
    assert abs(x - 1.0 / (2.0 * e_x)) < 1e-12
    lo, hi = 0.6939, 0.8309
    print(f"\n  Interval transfer from Lambda in [{lo}, {hi}]:")
    print(f"    X in [{gap_of_lam(hi):.5f}, {gap_of_lam(lo):.5f}]"
          f"   (booked [1.10175, 1.22054])")
    print("    => overshoot between 10% and 22%, policy-independent.\n")


def demo_nonidentifiability() -> None:
    """11. Non-identifiability of the coverage parameter."""
    print("=" * 74)
    print("11. THE TIGHTNESS-CIRCULARITY CATCH")
    print("=" * 74)
    print("  With qhat free, EVERY observed speed-up can be turned into an")
    print("  exact equality: q = 1/(Lam*Theta*S) always works, and is unique.\n")
    print(f"{'Lam':>8} {'Theta':>8} {'S observed':>12} {'fitted qhat':>13} "
          f"{'1/(L*T*q)':>12} {'Lam*Theta':>11}")
    rng = random.Random(7)
    for _ in range(5):
        lam = rng.uniform(0.4, 1.4)
        theta = rng.uniform(0.4, 1.4)
        s = rng.uniform(0.5, 4.0)
        q = 1.0 / (lam * theta * s)
        print(f"{lam:>8.4f} {theta:>8.4f} {s:>12.6f} {q:>13.6f} "
              f"{1.0 / (lam * theta * q):>12.6f} {lam * theta:>11.6f}")
        assert abs(1.0 / (lam * theta * q) - s) < 1e-9
    print("\n  Legacy-anchor construction, read off at Lam = Theta = 1:")
    for s in (1.10, 1.35, 2.00):
        print(f"    S = {s:.2f} -> qhat = 1/S = {1.0 / s:.6f} -> "
              f"bound = 1/(1*1*qhat) = {1.0 / (1.0 * 1.0 * (1.0 / s)):.6f} = S")
        assert abs(1.0 / (1.0 / s) - s) < 1e-12
    print("\n  The 'agreement' is an algebraic tautology, not evidence: an anchor")
    print("  whose parameters were obtained by inverting the law carries zero")
    print("  evidential weight for attainment.\n")


def demo_decidable_closer() -> None:
    """A two-sided prediction: measured profile, ascending policy."""
    print("=" * 74)
    print("12. THE FALSIFIABLE PREDICTION")
    print("=" * 74)
    lam = 0.765671
    predicted = 1.0 / lam
    bound = 1.0 / (lam * (2.0 * lam / (1.0 + lam)))
    print(f"  predicted speed-up of the window-ascending policy : {predicted:.4f}")
    print(f"  master bound at the measured parameters           : {bound:.4f}")
    print(f"  gap factor                                        : "
          f"{bound / predicted:.5f}")
    print("\n  Observing S near 1.31 confirms the mapping; observing S above")
    print("  1.51 would falsify it. A genuine two-sided test.\n")


def main() -> None:
    print()
    print("#" * 74)
    print("#  THE SLACK FACTOR OF THE SCAN SPEED-UP INEQUALITY")
    print("#  Numerical demonstrations")
    print("#" * 74)
    print()
    demos: List[Callable[[], None]] = [
        demo_conservation_and_identity_chain,
        demo_policy_audit,
        demo_sharpness_over_class,
        demo_dispersion,
        demo_fibration_and_range,
        demo_constrained_polytope,
        demo_refinement,
        demo_harmonic,
        demo_measured_profile,
        demo_nonidentifiability,
        demo_decidable_closer,
    ]
    for d in demos:
        d()
    print("=" * 74)
    print("All assertions passed.")
    print("=" * 74)


if __name__ == "__main__":
    main()
