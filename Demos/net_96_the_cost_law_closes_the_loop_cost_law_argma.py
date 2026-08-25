#!/usr/bin/env python3
"""
The Speculative-Decoding Cost Law — numerical demonstrations.

Self-contained (standard library only). Every function is inlined and type-hinted.

Covered results
---------------
 1. The cost law  G(d) = A(d) / (1 + c*d)  and the marginal test.
 2. The equilibrium law  M(d) < 0  <=>  s_d < c * G(d).
 3. Discrete concavity  M(d+1) - M(d) = (1 + c(d+1)) (s_{d+1} - s_d).
 4. Myopic stopping is globally exact for nonincreasing survival curves.
 5. Single crossing suffices — no monotonicity needed.
 6. The universal speedup ceiling  G(d) < 1/c.
 7. Geometric survival: closed form, Theta(log 1/c) depth law.
 8. Harmonic (Zipf) survival: divergent acceptance, finite optimum.
 9. No universal optimal depth (block survival witnesses).
10. Argmax stability under sup-norm perturbation.
11. Tight (2i+1) noise amplification of the differencing estimator.
12. The measured instance: prose argmax 4, code argmax 8, certified radius 1/100.
"""

from __future__ import annotations

import math
import random
from typing import Callable, List, Sequence, Tuple

# --------------------------------------------------------------------------- #
# Measured constants and data
# --------------------------------------------------------------------------- #

COST_RATE: float = 0.118  # drafted-token cost, in units of one verification pass

PROSE_SURV: Tuple[float, ...] = (0.670, 1.050, 0.420, 0.860, 0.119, 0.050, -0.030, 0.100)
CODE_SURV: Tuple[float, ...] = (0.820, 1.120, 0.910, 1.060, 0.780, 0.830, 0.740, 0.690)


# --------------------------------------------------------------------------- #
# Core functionals
# --------------------------------------------------------------------------- #

def accept(s: Sequence[float], d: int) -> float:
    """Cumulative acceptance A(d) = sum_{i<d} s_i (indices past len(s) are 0)."""
    return float(sum(s[i] for i in range(min(d, len(s)))))


def gain(c: float, s: Sequence[float], d: int) -> float:
    """The cost law G(d) = A(d) / (1 + c*d)."""
    return accept(s, d) / (1.0 + c * d)


def survival_at(s: Sequence[float], d: int) -> float:
    """s_d, with the zero extension past the measured horizon."""
    return float(s[d]) if d < len(s) else 0.0


def marginal(c: float, s: Sequence[float], d: int) -> float:
    """M(d) = s_d (1 + c d) - c A(d).  G(d) <= G(d+1)  iff  M(d) >= 0."""
    return survival_at(s, d) * (1.0 + c * d) - c * accept(s, d)


# --------------------------------------------------------------------------- #
# Algorithms
# --------------------------------------------------------------------------- #

def myopic_optimal_depth(c: float, s: Sequence[float], horizon: int) -> int:
    """First depth where the equilibrium test s_d < c*G(d) fires. Globally exact."""
    running: float = 0.0
    for d in range(horizon):
        throughput = running / (1.0 + c * d)
        if survival_at(s, d) < c * throughput:
            return d
        running += survival_at(s, d)
    return horizon


def brute_force_argmax(c: float, s: Sequence[float], horizon: int) -> int:
    """argmax of the cost law over {0, ..., horizon} by exhaustive evaluation."""
    return max(range(horizon + 1), key=lambda d: gain(c, s, d))


def certified_argmax(
    c: float, s: Sequence[float], horizon: int, eps: float
) -> Tuple[int, bool]:
    """Argmax plus a certificate that every curve within sup-distance eps agrees."""
    d0 = brute_force_argmax(c, s, horizon)
    g0 = gain(c, s, d0)
    for d in range(horizon + 1):
        if d == d0:
            continue
        budget = eps * d / (1.0 + c * d) + eps * d0 / (1.0 + c * d0)
        if budget >= g0 - gain(c, s, d):
            return d0, False
    return d0, True


def diff_surv(m: Sequence[float], i: int) -> float:
    """Differencing estimator  s_i = (i+1) m(i+1) - i m(i)."""
    return (i + 1) * m[i + 1] - i * m[i]


# --------------------------------------------------------------------------- #
# Survival families
# --------------------------------------------------------------------------- #

def geom_surv(r: float, n: int) -> List[float]:
    """Geometric survival s_i = r^i."""
    return [r ** i for i in range(n)]


def harm_surv(n: int) -> List[float]:
    """Harmonic (Zipf) survival s_i = 1/(i+1)."""
    return [1.0 / (i + 1) for i in range(n)]


def block_surv(width: int, n: int) -> List[float]:
    """Block survival: 1 for the first `width` positions, 0 after."""
    return [1.0 if i < width else 0.0 for i in range(n)]


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #

def rule(title: str) -> None:
    print("\n" + "=" * 74)
    print(title)
    print("=" * 74)


def demo_measured_instance() -> None:
    rule("1.  THE MEASURED INSTANCE  (c = 0.118, prose vs code)")
    for name, s, expected in (("prose", PROSE_SURV, 4), ("code", CODE_SURV, 8)):
        print(f"\n  {name} register")
        print(f"  {'d':>3} {'A(d)':>8} {'G(d)':>8} {'M(d)':>9} {'c*G(d)':>8} {'s_d':>8}")
        for d in range(1, 9):
            print(
                f"  {d:>3} {accept(s, d):>8.3f} {gain(c=COST_RATE, s=s, d=d):>8.4f} "
                f"{marginal(COST_RATE, s, d):>9.4f} "
                f"{COST_RATE * gain(COST_RATE, s, d):>8.4f} "
                f"{survival_at(s, d):>8.3f}"
            )
        arg = brute_force_argmax(COST_RATE, s, 40)
        myo = myopic_optimal_depth(COST_RATE, s, 40)
        print(f"  brute-force argmax over d<=40 : {arg}   (measured optimum {expected})")
        print(f"  myopic stopping rule          : {myo}")
        assert arg == expected == myo


def demo_equilibrium_law() -> None:
    rule("2.  THE EQUILIBRIUM LAW:  M(d) < 0  <=>  s_d < c * G(d)")
    s = PROSE_SURV
    print("  prose register, crossing of micro (s_d) against macro (c * G(d)):")
    for d in range(0, 8):
        lhs, rhs = survival_at(s, d), COST_RATE * gain(COST_RATE, s, d)
        agree = (marginal(COST_RATE, s, d) < 0) == (lhs < rhs)
        flag = "STOP" if lhs < rhs else "go deeper"
        print(f"    d={d}:  s_d={lhs:6.3f}   c*G(d)={rhs:6.4f}   -> {flag:<10} "
              f"[law holds: {agree}]")
        assert agree
    print("\n  First crossing at d = 4: s_4 = 0.119 < 0.118 * 2.0380 = 0.2405.")


def demo_discrete_concavity() -> None:
    rule("3.  DISCRETE CONCAVITY:  M(d+1) - M(d) = (1 + c(d+1)) (s_{d+1} - s_d)")
    s = geom_surv(0.8, 20)
    worst = 0.0
    for d in range(15):
        lhs = marginal(COST_RATE, s, d + 1) - marginal(COST_RATE, s, d)
        rhs = (1.0 + COST_RATE * (d + 1)) * (survival_at(s, d + 1) - survival_at(s, d))
        worst = max(worst, abs(lhs - rhs))
    print(f"  identity verified on geometric survival r=0.8, max residual {worst:.2e}")
    marg = [marginal(COST_RATE, s, d) for d in range(15)]
    print(f"  marginal is nonincreasing: {all(marg[i] >= marg[i + 1] for i in range(14))}")
    print("  marginals:", "  ".join(f"{m:+.3f}" for m in marg[:9]))


def demo_geometric_depth_law() -> None:
    rule("4.  GEOMETRIC SURVIVAL: Theta(log 1/c) DEPTH LAW")
    r = 0.8
    print(f"  s_i = {r}^i;  lower bound  floor(log((1-r)/c)/log(1/r)),")
    print("  upper bound  min{d >= 1 : r^d (1 + c d) < c}\n")
    print(f"  {'c':>8} {'d_lo':>6} {'d*':>4} {'d_hi':>6} {'G(d*)':>8} {'1/c':>8}")
    for c in (0.5, 0.25, 0.118, 0.05, 0.02, 0.01, 0.005):
        s = geom_surv(r, 400)
        d_lo = math.floor(math.log((1 - r) / c) / math.log(1 / r)) if c < 1 - r else 0
        d_hi = next(d for d in range(1, 400) if r ** d * (1 + c * d) < c)
        d_star = brute_force_argmax(c, s, 399)
        assert d_lo <= d_star <= d_hi, (c, d_lo, d_star, d_hi)
        print(f"  {c:>8.3f} {d_lo:>6} {d_star:>4} {d_hi:>6} "
              f"{gain(c, s, d_star):>8.3f} {1 / c:>8.3f}")
    print("\n  Depth grows like log(1/c): halving c adds log2/log(1/r) ~ 3.1.")
    print("  Every gain stays strictly below the ceiling 1/c.")
    print("\n  Calibrated instance c=0.118, r=0.8 -> optimal depth "
          f"{brute_force_argmax(0.118, geom_surv(0.8, 100), 99)} "
          "(between the measured 4 and 8).")


def demo_harmonic_finite_optimum() -> None:
    rule("5.  HARMONIC SURVIVAL: DIVERGENT ACCEPTANCE, FINITE OPTIMUM")
    print(f"  {'c':>8} {'d*':>6} {'A(d*)':>8} {'G(d*)':>8} {'A(10^4)':>10}")
    for c in (0.5, 0.118, 0.02, 0.005):
        n = 200000
        s = harm_surv(n)
        d_star = brute_force_argmax(c, s, 5000)
        print(f"  {c:>8.3f} {d_star:>6} {accept(s, d_star):>8.3f} "
              f"{gain(c, s, d_star):>8.3f} {accept(s, 10000):>10.3f}")
    print("\n  Cumulative acceptance diverges (harmonic series) yet the optimum is")
    print("  finite for every c > 0: benefit ~ log d, cost ~ 1 + c d.")


def demo_no_universal_depth() -> None:
    rule("6.  NO UNIVERSAL OPTIMAL DEPTH")
    print("  For each candidate d0, the block curve of width d0+1 prefers d0+1:")
    for d0 in (1, 2, 3, 5, 8, 13):
        s = block_surv(d0 + 1, 40)
        better = gain(COST_RATE, s, d0) < gain(COST_RATE, s, d0 + 1)
        print(f"    d0={d0:>3}:  G(d0)={gain(COST_RATE, s, d0):7.4f} < "
              f"G(d0+1)={gain(COST_RATE, s, d0 + 1):7.4f}   [{better}]")
        assert better
    print("\n  Measured counterpart: prose prefers 4, code prefers 8.")
    print(f"    G_prose(4)={gain(COST_RATE, PROSE_SURV, 4):.4f} > "
          f"G_prose(8)={gain(COST_RATE, PROSE_SURV, 8):.4f}")
    print(f"    G_code(8) ={gain(COST_RATE, CODE_SURV, 8):.4f} > "
          f"G_code(4) ={gain(COST_RATE, CODE_SURV, 4):.4f}")


def demo_argmax_stability() -> None:
    rule("7.  ARGMAX STABILITY UNDER SUP-NORM PERTURBATION")
    eps = 0.01
    for name, s, d0 in (("prose", PROSE_SURV, 4), ("code", CODE_SURV, 8)):
        arg, cert = certified_argmax(COST_RATE, s, 8, eps)
        g0 = gain(COST_RATE, s, d0)
        margins = [(d, g0 - gain(COST_RATE, s, d)) for d in range(1, 9) if d != d0]
        tight_d, tight_m = min(margins, key=lambda t: t[1])
        budget = eps * tight_d / (1 + COST_RATE * tight_d) + eps * d0 / (1 + COST_RATE * d0)
        print(f"\n  {name}: argmax={arg}, certified at eps={eps}: {cert}")
        print(f"    tightest rival d={tight_d}, margin {tight_m:.4f}, "
              f"perturbation budget {budget:.4f}")
        assert arg == d0 and cert

    print("\n  Monte-Carlo check (prose, 20000 random perturbations, |dt| <= 0.01):")
    rng = random.Random(42)
    bad = 0
    for _ in range(20000):
        t = [x + rng.uniform(-eps, eps) for x in PROSE_SURV]
        if brute_force_argmax(COST_RATE, t, 8) != 4:
            bad += 1
    print(f"    argmax != 4 in {bad} / 20000 trials.")
    assert bad == 0


def demo_noise_amplification() -> None:
    rule("8.  TIGHT (2i+1) NOISE AMPLIFICATION OF DIFFERENCING")
    delta = 0.05
    print(f"  Worst-case aggregate error delta = {delta}\n")
    print(f"  {'i':>3} {'bound (2i+1)d':>15} {'attained':>10} {'cumulative i*d':>15} "
          f"{'ratio':>7}")
    for i in range(0, 8):
        n = i + 3
        m = [0.0] * n
        m_bad = [0.0] * n
        m_bad[i + 1] = delta
        m_bad[i] = -delta
        attained = diff_surv(m_bad, i) - diff_surv(m, i)
        bound = (2 * i + 1) * delta
        cumulative = i * delta
        ratio = f"{bound / cumulative:>7.3f}" if i >= 1 else f"{'--':>7}"
        print(f"  {i:>3} {bound:>15.4f} {attained:>10.4f} {cumulative:>15.4f} {ratio}")
        assert abs(attained - bound) < 1e-12
    print("\n  The bound is attained by an alternating-sign error pattern; for i >= 1")
    print("  the ratio to the cumulative statistic lies in [3/2, 2) and tends to 2.")

    print("\n  Fragile estimates, robust conclusion: Monte-Carlo on a known truth")
    print("  s_i = 0.9 * 0.75^i, aggregate means perturbed by Gaussian noise.")
    horizon = 12
    truth = [0.9 * 0.75 ** i for i in range(horizon)]
    d_true = brute_force_argmax(COST_RATE, truth, horizon)
    g_true = gain(COST_RATE, truth, d_true)
    true_m = [accept(truth, d) / d if d > 0 else 0.0 for d in range(horizon + 1)]
    trials = 4000
    print(f"  true optimal depth {d_true}, true throughput {g_true:.4f}\n")
    print(f"  {'sigma':>7} {'||diff err||':>13} {'||cum err||':>12} {'ratio':>7} "
          f"{'inadmissible':>13} {'throughput regret':>18}")
    for sigma in (0.001, 0.005, 0.01, 0.02, 0.05):
        rng = random.Random(7)
        sup_diff = sup_cum = regret = 0.0
        bad_values = 0
        for _ in range(trials):
            noisy_m = [x + rng.gauss(0.0, sigma) for x in true_m]
            est = [diff_surv(noisy_m, i) for i in range(horizon)]
            sup_diff += max(abs(est[i] - truth[i]) for i in range(horizon))
            sup_cum += max(abs(d * noisy_m[d] - accept(truth, d))
                           for d in range(1, horizon + 1))
            if any(v < 0.0 or v > 1.0 for v in est):
                bad_values += 1
            d_hat = brute_force_argmax(COST_RATE, est, horizon)
            regret += (g_true - gain(COST_RATE, truth, d_hat)) / g_true
        print(f"  {sigma:>7.3f} {sup_diff / trials:>13.4f} {sup_cum / trials:>12.4f} "
              f"{sup_diff / sup_cum:>7.2f} {bad_values / trials:>12.1%} "
              f"{regret / trials:>17.2%}")
    print("\n  The pointwise curve is destroyed - already 68% of trials contain an")
    print("  impossible probability at sigma = 0.005 - while the throughput lost by")
    print("  acting on the estimated depth stays well under 1%. The argmax is a")
    print("  functional of the partial sums, in which the errors largely cancel.")


def demo_ceiling_and_tailsum() -> None:
    rule("9.  UNIVERSAL CEILING AND THE TAIL-SUM BRIDGE")
    print(f"  Ceiling at c = {COST_RATE}:  1/c = {1 / COST_RATE:.4f}")
    print(f"    best measured code throughput G(8) = "
          f"{gain(COST_RATE, CODE_SURV, 8):.4f}  (not saturated)")
    perfect = block_surv(10_000, 10_000)
    print(f"    perfect draft model, depth 5000    = "
          f"{gain(COST_RATE, perfect, 5000):.4f}  < {1 / COST_RATE:.4f}")

    print("\n  Tail-sum identity  A(d) = sum_{i<d}(i+1)(s_i - s_{i+1}) + d s_d :")
    s = geom_surv(0.75, 30)
    worst = 0.0
    for d in range(20):
        lhs = accept(s, d)
        rhs = sum((i + 1) * (survival_at(s, i) - survival_at(s, i + 1))
                  for i in range(d)) + d * survival_at(s, d)
        worst = max(worst, abs(lhs - rhs))
    print(f"    max residual over d <= 20: {worst:.2e}")
    print("    (cumulative acceptance = expected truncated run length)")


def demo_myopic_vs_sweep() -> None:
    rule("10.  MYOPIC STOPPING VS EXHAUSTIVE SWEEP")
    print(f"  {'family':>22} {'myopic':>8} {'brute':>7} {'evals saved':>12}")
    families: List[Tuple[str, List[float]]] = [
        ("geometric r=0.60", geom_surv(0.60, 200)),
        ("geometric r=0.80", geom_surv(0.80, 200)),
        ("geometric r=0.95", geom_surv(0.95, 200)),
        ("harmonic 1/(i+1)", harm_surv(2000)),
        ("block width 12", block_surv(12, 200)),
    ]
    for name, s in families:
        myo = myopic_optimal_depth(COST_RATE, s, 199)
        brute = brute_force_argmax(COST_RATE, s, 199)
        print(f"  {name:>22} {myo:>8} {brute:>7} {199 - myo:>12}")
        assert myo == brute


def main() -> None:
    print(__doc__)
    demo_measured_instance()
    demo_equilibrium_law()
    demo_discrete_concavity()
    demo_geometric_depth_law()
    demo_harmonic_finite_optimum()
    demo_no_universal_depth()
    demo_argmax_stability()
    demo_noise_amplification()
    demo_ceiling_and_tailsum()
    demo_myopic_vs_sweep()
    print("\n" + "=" * 74)
    print("All demonstrations completed; every assertion passed.")
    print("=" * 74)


if __name__ == "__main__":
    main()
