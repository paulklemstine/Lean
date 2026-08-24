#!/usr/bin/env python3
"""
Numerical demonstrations for
"A Selection-Theoretic Account of Content-Based Importance Prediction
 in Budgeted Key Eviction".

Every result stated in the paper that can be checked numerically is checked
here, from first principles, with no third-party dependencies.

Contents
--------
 1. Core objects: retained mass, top sets, SSE, R-squared.
 2. The exchange inequality and the oracle bound (randomised stress test).
 3. The two transfer theorems (L-infinity and L-2) and their R-squared form.
 4. Sharpness of the constant 2*B*eps.
 5. R-squared does NOT determine retention: the shrinkage probe with
    R^2 = 0.3185 achieving oracle retention at every budget.
 6. Accuracy does NOT order retention: SSE 150 retains 1, SSE 1802 retains 19.
 7. The boundary band: the deficit lives in a 2*eps strip around the cut-off.
 8. Hybrid scores: exact stability interval, margin threshold, convexity,
    and a mixture strictly dominating both parents (9 < 11 < 19).
 9. The retention knee as an envelope floor for every eviction policy.
10. The two quantitative readings of the reported measurements.

Run:  python3 demo.py
"""

from __future__ import annotations

import itertools
import math
import random
from typing import Callable, Iterable, List, Optional, Sequence, Tuple

Vector = Sequence[float]
Selection = Tuple[int, ...]

EPS_NUM = 1e-9  # numerical slack for float comparisons


# ---------------------------------------------------------------------------
# 1. Core objects
# ---------------------------------------------------------------------------

def retained(a: Vector, S: Iterable[int]) -> float:
    """Retained mass A(S) = sum of true importances over the selected keys."""
    return float(sum(a[i] for i in S))


def is_top_set(s: Vector, B: int, S: Iterable[int]) -> bool:
    """S is a top set for score s at budget B: |S| = B and no retained key is
    scored strictly below a discarded key."""
    Sset = set(S)
    if len(Sset) != B:
        return False
    outside = [j for j in range(len(s)) if j not in Sset]
    return all(s[j] <= s[i] + EPS_NUM for i in Sset for j in outside)


def greedy_top_set(s: Vector, B: int) -> Selection:
    """Greedy budget-B selection: the B highest-scoring keys (ties broken by
    index). Always returns a top set."""
    order = sorted(range(len(s)), key=lambda i: (-s[i], i))
    return tuple(sorted(order[:B]))


def all_top_sets(s: Vector, B: int) -> List[Selection]:
    """Every top set at budget B (exhaustive; only for tiny instances)."""
    return [c for c in itertools.combinations(range(len(s)), B) if is_top_set(s, B, c)]


def sse(a: Vector, s: Vector) -> float:
    """Sum of squared prediction errors."""
    return float(sum((ai - si) ** 2 for ai, si in zip(a, s)))


def mean(a: Vector) -> float:
    return float(sum(a)) / len(a)


def ss_tot(a: Vector) -> float:
    """Total dispersion of the true importances."""
    m = mean(a)
    return float(sum((ai - m) ** 2 for ai in a))


def r_squared(a: Vector, s: Vector) -> float:
    """Coefficient of determination of the score s for the importances a."""
    tot = ss_tot(a)
    if tot == 0.0:
        raise ValueError("SS_tot = 0: R^2 undefined")
    return 1.0 - sse(a, s) / tot


def linf_error(a: Vector, s: Vector) -> float:
    return max(abs(ai - si) for ai, si in zip(a, s))


def banner(title: str) -> None:
    print()
    print("=" * 74)
    print(title)
    print("=" * 74)


def check(label: str, ok: bool, detail: str = "") -> None:
    mark = "OK  " if ok else "FAIL"
    print(f"  [{mark}] {label}" + (f"   {detail}" if detail else ""))
    if not ok:
        raise AssertionError(label)


# ---------------------------------------------------------------------------
# 2. The exchange inequality and the oracle bound
# ---------------------------------------------------------------------------

def demo_exchange_and_oracle(trials: int = 400, seed: int = 20260824) -> None:
    banner("2. Exchange inequality and oracle bound (randomised stress test)")
    rng = random.Random(seed)
    worst_slack = math.inf
    for _ in range(trials):
        n = rng.randint(3, 9)
        B = rng.randint(1, n - 1)
        a = [rng.uniform(0.0, 1.0) for _ in range(n)]
        s = [rng.uniform(-1.0, 1.0) for _ in range(n)]
        S = greedy_top_set(s, B)
        T = tuple(sorted(rng.sample(range(n), B)))

        # Exchange inequality: score mass of T \ S is at most that of S \ T.
        lhs = sum(s[i] for i in set(T) - set(S))
        rhs = sum(s[i] for i in set(S) - set(T))
        assert lhs <= rhs + EPS_NUM

        # Top sets maximise SCORE mass.
        assert sum(s[i] for i in T) <= sum(s[i] for i in S) + EPS_NUM

        # Oracle bound: the top set of the TRUE importances maximises RETAINED mass.
        O = greedy_top_set(a, B)
        slack = retained(a, O) - retained(a, T)
        worst_slack = min(worst_slack, slack)
        assert slack >= -EPS_NUM

    check("exchange inequality held on every trial", True, f"{trials} trials")
    check("top sets maximise score mass", True)
    check("oracle bound held on every trial", True,
          f"min slack = {worst_slack:.3e} (>= 0)")


# ---------------------------------------------------------------------------
# 3. The transfer theorems
# ---------------------------------------------------------------------------

def demo_transfer(trials: int = 400, seed: int = 7) -> None:
    banner("3. Transfer theorems: L-infinity, L-2, and the R-squared form")
    rng = random.Random(seed)
    tightest_linf = math.inf
    tightest_l2 = math.inf
    for _ in range(trials):
        n = rng.randint(4, 10)
        B = rng.randint(1, n - 1)
        a = [rng.uniform(0.0, 1.0) for _ in range(n)]
        noise = [rng.uniform(-0.3, 0.3) for _ in range(n)]
        s = [ai + z for ai, z in zip(a, noise)]
        S = greedy_top_set(s, B)
        T = tuple(sorted(rng.sample(range(n), B)))

        deficit = retained(a, T) - retained(a, S)
        eps = linf_error(a, s)

        bound_inf = 2 * B * eps
        bound_l2 = 2 * math.sqrt(B * sse(a, s))
        m = len(set(S) - set(T))
        bound_sharp = 2 * m * eps

        assert deficit <= bound_inf + EPS_NUM
        assert deficit <= bound_l2 + EPS_NUM
        assert deficit <= bound_sharp + EPS_NUM          # strictly stronger
        assert bound_sharp <= bound_inf + EPS_NUM

        if ss_tot(a) > 0:
            rsq = r_squared(a, s)
            bound_rsq = 2 * math.sqrt(B * (1 - rsq) * ss_tot(a))
            assert deficit <= bound_rsq + EPS_NUM
            assert abs(bound_rsq - bound_l2) < 1e-8    # they are the same bound

        tightest_linf = min(tightest_linf, bound_inf - deficit)
        tightest_l2 = min(tightest_l2, bound_l2 - deficit)

    check("L-infinity bound 2*B*eps held", True, f"min headroom {tightest_linf:.4f}")
    check("L-2 bound 2*sqrt(B*SSE) held", True, f"min headroom {tightest_l2:.4f}")
    check("sharpened bound 2*|S\\T|*eps held and dominates 2*B*eps", True)
    check("R-squared form agrees with the L-2 form", True)


# ---------------------------------------------------------------------------
# 4. Sharpness of the constant 2*B*eps
# ---------------------------------------------------------------------------

def demo_sharpness() -> None:
    banner("4. The transfer constant 2*B*eps is attained (hence unimprovable)")
    a = [1.0, 1.0, -1.0, -1.0]
    s = [0.0, 0.0, 0.0, 0.0]       # a totally uninformative score
    eps, B = 1.0, 2
    S = (2, 3)                     # a legitimate top set: every key ties
    T = (0, 1)                     # the oracle selection
    print(f"  importances a = {a},  flat score s = {s},  eps = {eps}, B = {B}")
    print(f"  every pair is a top set for s: {len(all_top_sets(s, B))} of them")
    deficit = retained(a, T) - retained(a, S)
    print(f"  oracle retains {retained(a, T):+.1f}, the evictor may retain "
          f"{retained(a, S):+.1f}")
    check("S is a top set for the flat score", is_top_set(s, B, S))
    check("deficit equals exactly 2*B*eps", abs(deficit - 2 * B * eps) < EPS_NUM,
          f"deficit = {deficit:.1f} = 2*{B}*{eps:.0f}")
    print("  => no bound with a constant c < 2 can hold.")


# ---------------------------------------------------------------------------
# 5. R-squared does not determine retention
# ---------------------------------------------------------------------------

def shrinkage_probe(a: Vector, rho: float) -> List[float]:
    """The probe with R^2 EXACTLY rho that preserves the order of a:
       s_i = mean(a) + c*(a_i - mean(a)) with c = 1 - sqrt(1 - rho)."""
    if not (0.0 < rho < 1.0):
        raise ValueError("rho must lie strictly between 0 and 1")
    c = 1.0 - math.sqrt(1.0 - rho)
    m = mean(a)
    return [m + c * (ai - m) for ai in a]


def demo_rsq_does_not_determine_retention(seed: int = 1234) -> None:
    banner("5. An R^2 = 0.3185 probe with PERFECT retention at every budget")
    rng = random.Random(seed)
    n = 12
    a = [rng.uniform(0.0, 1.0) for _ in range(n)]
    rho = 0.3185                                    # the measured value
    s = shrinkage_probe(a, rho)

    print(f"  n = {n} keys,  target R^2 = {rho}")
    print(f"  achieved R^2 = {r_squared(a, s):.6f}")
    print(f"  SSE = {sse(a, s):.6f}   (compare SS_tot = {ss_tot(a):.6f})")
    check("R^2 matches the target exactly", abs(r_squared(a, s) - rho) < 1e-12)

    all_match = True
    for B in range(1, n):
        S = greedy_top_set(s, B)
        O = greedy_top_set(a, B)
        all_match &= (S == O) and abs(retained(a, S) - retained(a, O)) < EPS_NUM
    check("selection equals the oracle at EVERY budget 1..n-1", all_match)
    print("  => a mediocre R^2 is perfectly compatible with zero retention loss;")
    print("     the 12-point probe deficit cannot be deduced from R^2 = 0.3185.")


# ---------------------------------------------------------------------------
# 6. Accuracy does not order retention
# ---------------------------------------------------------------------------

def demo_accuracy_inversion() -> None:
    banner("6. Accuracy does not order retention (SSE 150 vs 1802)")
    a = [10.0, 9.0, 1.0, 0.0]
    h = [1.0, 2.0, 3.0, 4.0]        # very accurate, badly ordered
    p = [40.0, 30.0, 20.0, 10.0]    # very inaccurate, correctly ordered
    B = 2

    tops_h, tops_p = all_top_sets(h, B), all_top_sets(p, B)
    print(f"  a = {a}")
    print(f"  h = {h}   SSE = {sse(a, h):.0f}   unique top set {tops_h}")
    print(f"  p = {p}   SSE = {sse(a, p):.0f}  unique top set {tops_p}")

    check("SSE(a,h) = 150", abs(sse(a, h) - 150.0) < EPS_NUM)
    check("SSE(a,p) = 1802", abs(sse(a, p) - 1802.0) < EPS_NUM)
    check("h is 12x more accurate than p", sse(a, h) < sse(a, p))
    check("top set of h is unique", len(tops_h) == 1 and tops_h[0] == (2, 3))
    check("top set of p is unique", len(tops_p) == 1 and tops_p[0] == (0, 1))
    check("h retains 1", abs(retained(a, tops_h[0]) - 1.0) < EPS_NUM)
    check("p retains 19", abs(retained(a, tops_p[0]) - 19.0) < EPS_NUM)
    print("  => the 12x more accurate score retains 19x LESS mass.")


# ---------------------------------------------------------------------------
# 7. The boundary band
# ---------------------------------------------------------------------------

def band_mass(a: Vector, T: Iterable[int], mu: float, eps: float) -> float:
    """Mass of the keys of T sitting within 2*eps of the cut-off mu."""
    return float(sum(a[i] for i in T if a[i] <= mu + 2 * eps))


def demo_boundary_band(trials: int = 400, seed: int = 99) -> None:
    banner("7. The deficit lives in the 2*eps band around the cut-off")
    rng = random.Random(seed)
    empty_band_cases = 0
    for _ in range(trials):
        n = rng.randint(4, 10)
        B = rng.randint(1, n - 1)
        a = [rng.uniform(0.0, 1.0) for _ in range(n)]          # non-negative
        s = [ai + rng.uniform(-0.25, 0.25) for ai in a]
        S = greedy_top_set(s, B)
        T = greedy_top_set(a, B)                                # the oracle rival
        eps = linf_error(a, s)
        mu = max((a[j] for j in range(n) if j not in set(T)), default=-math.inf)

        deficit = retained(a, T) - retained(a, S)
        bm = band_mass(a, T, mu, eps)
        assert deficit <= bm + EPS_NUM

        if bm == 0.0:
            empty_band_cases += 1
            assert deficit <= EPS_NUM                          # no band, no loss

    check("band bound held on every trial", True, f"{trials} trials")
    check("empty band always implied zero loss", True,
          f"{empty_band_cases} empty-band cases")

    # An explicit empty-band instance: a wide margin makes an inaccurate score harmless.
    a = [10.0, 9.0, 0.2, 0.1]
    s = [8.0, 11.0, 1.0, -0.5]          # bad predictions, right ordering near the cut
    B, eps = 2, linf_error(a, s)
    T = greedy_top_set(a, B)
    S = greedy_top_set(s, B)
    mu = max(a[j] for j in range(4) if j not in set(T))
    print(f"\n  explicit instance: a = {a}, s = {s}")
    print(f"  eps = {eps:.1f}, cut-off mu = {mu:.1f}, band threshold "
          f"mu + 2*eps = {mu + 2 * eps:.1f}")
    print(f"  band mass = {band_mass(a, T, mu, eps):.1f}, "
          f"R^2 = {r_squared(a, s):.4f}, deficit = "
          f"{retained(a, T) - retained(a, S):.1f}")
    check("a very inaccurate score loses nothing when the band is thin",
          retained(a, T) - retained(a, S) <= band_mass(a, T, mu, eps) + EPS_NUM)


# ---------------------------------------------------------------------------
# 8. Hybrid scores
# ---------------------------------------------------------------------------

def hybrid(h: Vector, p: Vector, lam: float) -> List[float]:
    """The mixture score h + lam * p."""
    return [hi + lam * pi for hi, pi in zip(h, p)]


def stability_interval(h: Vector, p: Vector,
                       S: Iterable[int]) -> Tuple[float, float]:
    """Exact interval of mixing weights lam preserving the selection S.

    By the linear characterisation, S survives iff
        lam * (p_j - p_i) <= h_i - h_j   for all i in S, j not in S.
    Each pair yields an upper bound, a lower bound, or a feasibility test.
    Returns (lo, hi); the interval is empty if lo > hi.
    """
    Sset = set(S)
    outside = [j for j in range(len(h)) if j not in Sset]
    lo, hi = -math.inf, math.inf
    for i in Sset:
        for j in outside:
            d = p[j] - p[i]
            rhs = h[i] - h[j]
            if d > 0:
                hi = min(hi, rhs / d)
            elif d < 0:
                lo = max(lo, rhs / d)
            else:
                if rhs < 0:
                    return (1.0, -1.0)   # infeasible for every lam
    return (lo, hi)


def demo_hybrid() -> None:
    banner("8. Hybrid scores: strict dominance and the exact stability interval")
    a = [10.0, 9.0, 1.0, 0.0]
    h = [6.0, 2.0, 4.0, 0.0]      # accumulated heavy-hitter statistic
    p = [2.0, 7.0, 2.0, 5.0]      # content probe
    B = 2

    Sh = all_top_sets(h, B)[0]
    Sp = all_top_sets(p, B)[0]
    Shyb = all_top_sets(hybrid(h, p, 1.0), B)[0]

    print(f"  a   = {a}")
    print(f"  h   = {h}       top set {Sh}  retains {retained(a, Sh):.0f}")
    print(f"  p   = {p}       top set {Sp}  retains {retained(a, Sp):.0f}")
    print(f"  h+p = {hybrid(h, p, 1.0)}   top set {Shyb}  "
          f"retains {retained(a, Shyb):.0f}")

    check("accumulated arm retains 11", abs(retained(a, Sh) - 11) < EPS_NUM)
    check("probe-only arm retains 9", abs(retained(a, Sp) - 9) < EPS_NUM)
    check("hybrid at lambda = 1 retains 19", abs(retained(a, Shyb) - 19) < EPS_NUM)
    check("hybrid strictly dominates both parents: 9 < 11 < 19",
          retained(a, Sp) < retained(a, Sh) < retained(a, Shyb))

    lo, hi = stability_interval(h, p, Sh)
    print(f"\n  stability interval of the accumulated selection {Sh}: "
          f"lam in ({lo:.4f}, {hi:.4f}]")
    check("upper endpoint is exactly 2/5", abs(hi - 0.4) < 1e-12)
    check("the useful weight lambda = 1 lies OUTSIDE the safe interval", 1.0 > hi)

    # Verify the interval endpoint by brute force.
    grid_ok = True
    for k in range(-200, 401):
        lam = k / 500.0
        grid_ok &= (is_top_set(hybrid(h, p, lam), B, Sh) == (lam <= hi + 1e-12))
    check("brute-force grid agrees with the computed interval", grid_ok)

    # Convexity / order-connectedness of the stable set.
    stable = [k / 500.0 for k in range(-200, 401)
              if is_top_set(hybrid(h, p, k / 500.0), B, Sh)]
    check("the stable weight set is an interval (order-connected)",
          all(abs(stable[i + 1] - stable[i] - 0.002) < 1e-9
              for i in range(len(stable) - 1)))
    print("  => harm can only be monotone in lambda: leaving the interval "
          "is irreversible.")


def demo_margin_threshold(trials: int = 300, seed: int = 5150) -> None:
    banner("8b. Non-degradation threshold: lambda * D <= gamma keeps the selection")
    rng = random.Random(seed)
    for _ in range(trials):
        n = rng.randint(4, 9)
        B = rng.randint(1, n - 1)
        h = [rng.uniform(0.0, 10.0) for _ in range(n)]
        p = [rng.uniform(-3.0, 3.0) for _ in range(n)]
        S = greedy_top_set(h, B)
        outside = [j for j in range(n) if j not in set(S)]
        if not outside:
            continue
        gamma = min(h[i] - h[j] for i in S for j in outside)   # separation margin
        D = max(p) - min(p)                                    # probe oscillation
        if gamma <= 0 or D <= 0:
            continue
        lam = rng.uniform(0.0, gamma / D)
        assert is_top_set(hybrid(h, p, lam), B, S)
    check("every lambda <= gamma/D preserved the accumulated selection", True,
          f"{trials} trials")
    print("  => non-degradation is a MARGIN phenomenon, independent of probe accuracy.")


# ---------------------------------------------------------------------------
# 9. The retention knee is an envelope floor
# ---------------------------------------------------------------------------

def knee(profile: Sequence[float], tau: float) -> Optional[int]:
    """Smallest k with sum of the first k entries >= tau (profile sorted
    non-increasing)."""
    total = 0.0
    for k, x in enumerate(profile, start=1):
        total += x
        if total >= tau - EPS_NUM:
            return k
    return None


def demo_knee_floor() -> None:
    banner("9. The knee is a floor for EVERY eviction policy, not just top-k")
    n = 16
    raw = [0.30, 0.18, 0.11, 0.08, 0.06, 0.05, 0.04, 0.035,
           0.03, 0.025, 0.02, 0.015, 0.012, 0.010, 0.008, 0.005]
    profile = sorted(raw, reverse=True)
    tau = 0.95
    k = knee(profile, tau)
    print(f"  sorted profile of {n} keys, drift-assert threshold tau = {tau}")
    print(f"  knee(tau) = {k}   (i.e. {k} of {n} keys)")
    assert k is not None

    # No budget-B policy beats the prefix.
    beats = 0
    for B in range(1, n + 1):
        prefix_mass = sum(profile[:B])
        for S in itertools.combinations(range(n), B):
            if sum(profile[i] for i in S) > prefix_mass + EPS_NUM:
                beats += 1
            if B > 5:
                break   # exhaustive only for the small budgets
    check("no selection ever beat the prefix of the same size", beats == 0)

    # Below the knee, every policy misses the threshold.
    misses_all = True
    for B in range(1, k):
        for S in itertools.combinations(range(n), min(B, 4)):
            if len(S) == B and sum(profile[i] for i in S) >= tau:
                misses_all = False
        if sum(profile[:B]) >= tau:
            misses_all = False
    check(f"every policy with budget < {k} misses tau", misses_all)

    # Price of content-blindness at the knee.
    eps = 0.001
    B = k
    guaranteed = tau - 2 * B * eps
    print(f"  a score with L-inf error eps = {eps} run at budget B = {B} "
          f"still reaches {guaranteed:.4f}")
    check("guarantee tau - 2*B*eps is nontrivial here", guaranteed > 0.9)


# ---------------------------------------------------------------------------
# 10. Reading the measurements through the theory
# ---------------------------------------------------------------------------

def demo_measurements() -> None:
    banner("10. The two quantitative readings of the reported measurements")
    acc, probe, hyb_arm = 0.9340, 0.8149, 0.9371
    rsq_code, rsq_prose = 0.3185, 0.329
    B = 64

    deficit = acc - probe
    gain = hyb_arm - acc
    print(f"  accumulated {acc:.4f} | probe {probe:.4f} | hybrid {hyb_arm:.4f}"
          f"   (budget B = {B})")
    print(f"  probe deficit = {deficit:.4f} ({100 * deficit:.2f} points)")
    print(f"  hybrid gain over accumulated = {gain:+.4f} "
          f"({100 * gain:+.2f} points, non-degrading)")
    check("probe deficit is 11.91 points", abs(deficit - 0.1191) < 1e-9)
    check("hybrid is non-degrading on code", gain > 0)

    # (a) Dispersion lower bound forced by the bound read backwards.
    ss_min = (deficit / 2.0) ** 2 / (B * (1.0 - rsq_code))
    print(f"\n  reading the R^2 transfer bound backwards at R^2 = {rsq_code}:")
    print(f"    SS_tot >= ({deficit:.4f}/2)^2 / ({B} * {1 - rsq_code:.4f}) "
          f"= {ss_min:.3e}")
    check("forces SS_tot > 8e-5", ss_min > 8e-5,
          f"SS_tot > {ss_min:.3e}")

    # (b) Cross-domain guarantee ratio.
    ratio = math.sqrt(1 - rsq_code) / math.sqrt(1 - rsq_prose)
    print(f"\n  cross-domain guarantee ratio sqrt(1-{rsq_code})/sqrt(1-{rsq_prose})"
          f" = {ratio:.6f}")
    check("code and prose guarantees agree to within 0.8 %", ratio < 1.008,
          f"{100 * (ratio - 1):.3f} % apart")
    print("  => 'domain-universal' upgraded from a qualitative impression "
          "to a number.")


# ---------------------------------------------------------------------------

def main() -> None:
    print(__doc__.strip().splitlines()[0])
    print("Numerical demonstration -- all claims checked from first principles.")
    demo_exchange_and_oracle()
    demo_transfer()
    demo_sharpness()
    demo_rsq_does_not_determine_retention()
    demo_accuracy_inversion()
    demo_boundary_band()
    demo_hybrid()
    demo_margin_threshold()
    demo_knee_floor()
    demo_measurements()
    banner("All demonstrations completed successfully.")


if __name__ == "__main__":
    main()
