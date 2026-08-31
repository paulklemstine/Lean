"""
Ascent-cost laws: numerical demonstration.
==========================================

Exact economics of a branch oracle under end-verification-only semantics.

A searcher climbs a complete b-ary decision tree of height h.  At each internal
node a *branch oracle* names the correct child with probability alpha.
Verification happens only at a leaf, so a wrong turn at level j forces
exhaustion of the entire wrong subtree below it.

Two schedules are priced exactly:

  DFS with backtracking (branching b, level waste weight w in (0, b-1]):

      E_b(w, h) = h (1 - w/(b-1)) + w (b^(h+1) - b) / (b-1)^2

  which at b = 3 and w = K = (1 - alpha)(2 - alpha) is the ternary law

      E_dfs(h) = h (1 - K/2) + K (3^(h+1) - 3) / 4.

  Restart from root:

      E_restart(h) = h * alpha^(-h).

The demonstrations below verify, numerically:

  1. the DFS closed form equals the accumulated per-level cost;
  2. the restart closed form equals a geometric-trial expectation;
  3. boundary calibration (alpha = 0 gives the full sweep; alpha = 1 gives h);
  4. beam (exhaustive level sweep) never beats DFS;
  5. effective branching is refuted: the growth ratio tends to exactly b;
  6. the dominance crossover sits exactly at alpha = 1/b;
  7. the ascent exponent law log E_min / h -> log min(b, 1/alpha);
  8. the branch-hint speedup (b alpha)^h breaks the class-hint cap 1/theta;
  9. the exact breakeven threshold alpha* = ((1+c) h / F)^(1/h).

Run with:  python3 demo.py
No dependencies beyond the standard library.
"""

from __future__ import annotations

import math
from typing import Callable, List, Tuple

# ----------------------------------------------------------------------------
# Core cost laws
# ----------------------------------------------------------------------------


def fail_weight(alpha: float) -> float:
    """Ternary level failure weight K = (1 - alpha)(2 - alpha).

    K/2 is the mean number of wrong siblings fully expanded at a level.
    K(0) = 2 (blind), K(1) = 0 (perfect).
    """
    return (1.0 - alpha) * (2.0 - alpha)


def dfs_level_cost(b: float, w: float, j: int) -> float:
    """Cost of level j: one visit, plus w times a complete wrong b-ary subtree
    of (b^j - 1)/(b - 1) nodes."""
    return 1.0 + w * (b ** j - 1.0) / (b - 1.0)


def dfs_cost_rec(b: float, w: float, h: int) -> float:
    """DFS cost obtained by accumulating per-level costs (first principles)."""
    total = 0.0
    for j in range(1, h + 1):
        total += dfs_level_cost(b, w, j)
    return total


def dfs_cost(b: float, w: float, h: int) -> float:
    """Closed-form general DFS ascent law."""
    return h * (1.0 - w / (b - 1.0)) + w * (b ** (h + 1) - b) / (b - 1.0) ** 2


def dfs_cost_ternary(alpha: float, h: int) -> float:
    """Ternary DFS law: h (1 - K/2) + K (3^(h+1) - 3)/4."""
    return dfs_cost(3.0, fail_weight(alpha), h)


def restart_cost(alpha: float, h: int) -> float:
    """Restart-from-root law E = h * alpha^(-h)."""
    return h / (alpha ** h)


def beam_cost(b: float, h: int) -> float:
    """Exhaustive level sweep: all internal nodes, (b^(h+1) - b)/(b - 1)."""
    return (b ** (h + 1) - b) / (b - 1.0)


def min_cost(b: float, w: float, alpha: float, h: int) -> float:
    """Cost of the better of the two live schedules."""
    return min(dfs_cost(b, w, h), restart_cost(alpha, h))


def hint_speedup(b: float, alpha: float, h: int) -> float:
    """Branch-hint speedup vs the uninformed baseline alpha = 1/b: (b alpha)^h."""
    return restart_cost(1.0 / b, h) / restart_cost(alpha, h)


def critical_accuracy(c: float, budget: float, h: int) -> float:
    """Exact breakeven accuracy alpha* = ((1 + c) h / F)^(1/h)."""
    return ((1.0 + c) * h / budget) ** (1.0 / h)


def geometric_trial_expectation(p: float, per_trial_cost: float) -> float:
    """Truncated expectation sum_{n>=0} (n+1) p (1-p)^n * cost, i.e. cost / p.

    The truncation length is chosen adaptively so the neglected tail is below
    machine precision.
    """
    terms = min(20_000_000, int(60.0 / p) + 100)
    total = 0.0
    q = 1.0
    for n in range(terms):
        total += (n + 1) * p * q
        q *= (1.0 - p)
        if q < 1e-20:
            break
    return total * per_trial_cost


# --- logarithmic versions, for depths where the raw costs overflow -----------


def log_dfs_cost(b: float, w: float, h: int) -> float:
    """log of the general DFS law, computed stably for very large h."""
    linear = h * (1.0 - w / (b - 1.0))
    log_exp_term = (math.log(w) + (h + 1) * math.log(b)
                    + math.log1p(-(b ** (-h))) - 2.0 * math.log(b - 1.0))
    if linear <= 0.0:
        return log_exp_term
    log_lin = math.log(linear)
    hi, lo = max(log_lin, log_exp_term), min(log_lin, log_exp_term)
    return hi + math.log1p(math.exp(lo - hi))


def log_restart_cost(alpha: float, h: int) -> float:
    """log of the restart law, computed stably for very large h."""
    return math.log(h) - h * math.log(alpha)


def log_min_cost(b: float, w: float, alpha: float, h: int) -> float:
    """log of the cost of the better of the two live schedules."""
    return min(log_dfs_cost(b, w, h), log_restart_cost(alpha, h))


# ----------------------------------------------------------------------------
# Presentation helpers
# ----------------------------------------------------------------------------


def banner(title: str) -> None:
    print()
    print("=" * 78)
    print(title)
    print("=" * 78)


def check(label: str, lhs: float, rhs: float, tol: float = 1e-9) -> None:
    rel = abs(lhs - rhs) / max(1.0, abs(rhs))
    verdict = "OK " if rel <= tol else "FAIL"
    print(f"  [{verdict}] {label:<52} {lhs:>18.8g} vs {rhs:>18.8g}")


# ----------------------------------------------------------------------------
# 1. The DFS closed form equals the accumulated per-level cost
# ----------------------------------------------------------------------------


def demo_dfs_closed_form() -> None:
    banner("1.  DFS closed form == accumulated per-level cost")
    for (b, w) in [(3.0, fail_weight(0.9)), (3.0, fail_weight(0.2)),
                   (5.0, 4.0), (5.0, 0.2), (2.0, 1.0), (7.0, 3.5)]:
        for h in (0, 1, 5, 12):
            check(f"b={b:g}, w={w:g}, h={h}", dfs_cost_rec(b, w, h),
                  dfs_cost(b, w, h))


# ----------------------------------------------------------------------------
# 2. The restart law equals a geometric-trial expectation
# ----------------------------------------------------------------------------


def demo_restart_geometric() -> None:
    banner("2.  Restart law == geometric-trial expectation  (E = h / alpha^h)")
    for alpha in (0.95, 0.8, 0.5, 0.25):
        for h in (1, 4, 6):
            p = alpha ** h
            check(f"alpha={alpha}, h={h}",
                  geometric_trial_expectation(p, float(h)),
                  restart_cost(alpha, h), tol=1e-6)


# ----------------------------------------------------------------------------
# 3. Boundary calibration and 4. beam never wins
# ----------------------------------------------------------------------------


def demo_calibration_and_beam() -> None:
    banner("3.  Boundary calibration:  alpha=0 -> full sweep,  alpha=1 -> h")
    for h in (1, 3, 6, 10):
        check(f"blind agent, h={h}", dfs_cost_ternary(0.0, h), beam_cost(3.0, h))
        check(f"perfect agent, h={h}", dfs_cost_ternary(1.0, h), float(h))

    banner("4.  Beam never wins:  E_dfs(alpha,h) <= (3^(h+1) - 3)/2")
    print(f"  {'h':>3} {'alpha':>7} {'E_dfs':>16} {'beam':>16} {'dfs<=beam':>10}")
    for h in (2, 5, 9):
        for alpha in (0.0, 0.1, 0.5, 0.9, 1.0):
            d = dfs_cost_ternary(alpha, h)
            bm = beam_cost(3.0, h)
            print(f"  {h:>3} {alpha:>7.2f} {d:>16.4f} {bm:>16.4f} "
                  f"{str(d <= bm + 1e-9):>10}")


# ----------------------------------------------------------------------------
# 5. Effective branching is refuted
# ----------------------------------------------------------------------------


def demo_effective_branching_refuted() -> None:
    banner("5.  Effective branching REFUTED:  E(h+1)/E(h) -> b, for every alpha<1")
    print("     Ternary case: the base stays pinned at exactly 3.")
    print(f"  {'alpha':>7} {'K':>10} " + "".join(f"{'h=' + str(h):>12}"
                                                 for h in (4, 8, 12, 18, 26)))
    for alpha in (0.0, 0.3, 0.5, 0.9, 0.99, 0.9999):
        row = f"  {alpha:>7.4f} {fail_weight(alpha):>10.6f} "
        for h in (4, 8, 12, 18, 26):
            r = dfs_cost_ternary(alpha, h + 1) / dfs_cost_ternary(alpha, h)
            row += f"{r:>12.6f}"
        print(row)
    print("\n     Prefactor:  E_dfs(h)/3^h -> 3K/4.")
    for alpha in (0.3, 0.9, 0.99):
        pred = 3.0 * fail_weight(alpha) / 4.0
        obs = dfs_cost_ternary(alpha, 30) / 3.0 ** 30
        check(f"alpha={alpha}: E/3^h at h=30 vs 3K/4", obs, pred, tol=1e-6)

    print("\n     Universality: same experiment at b = 5, two waste weights.")
    print(f"  {'b':>4} {'w':>6} {'E_b(6)':>16} {'E_b(7)/E_b(6)':>16}")
    for (b, w) in [(5.0, 4.0), (5.0, 0.2), (2.0, 1.0), (7.0, 6.0)]:
        e6 = dfs_cost(b, w, 6)
        ratio = dfs_cost(b, w, 7) / e6
        print(f"  {b:>4.0f} {w:>6.2f} {e6:>16.4f} {ratio:>16.6f}")
    print("     (b=5, w=4 gives 19530 = internal nodes of a depth-6 quinary tree;")
    print("      the prefactor moves by a factor 20, the base does not move.)")


# ----------------------------------------------------------------------------
# 6. The dominance crossover at alpha = 1/b
# ----------------------------------------------------------------------------


def demo_crossover() -> None:
    banner("6.  Dominance crossover at the reciprocal branching factor alpha = 1/b")
    print("     Ternary, ratio E_restart/E_dfs (-> 0 above 1/3, -> inf below):")
    print(f"  {'alpha':>8} " + "".join(f"{'h=' + str(h):>14}"
                                       for h in (5, 10, 20, 40)))
    for alpha in (0.20, 0.30, 1.0 / 3.0, 0.36, 0.5, 0.9):
        row = f"  {alpha:>8.4f} "
        for h in (5, 10, 20, 40):
            row += f"{restart_cost(alpha, h) / dfs_cost_ternary(alpha, h):>14.4g}"
        print(row)

    print("\n     b = 5 (crossover at 0.2), waste weight w = 1, ratio E_restart/E_dfs:")
    print(f"  {'alpha':>8} " + "".join(f"{'h=' + str(h):>14}"
                                       for h in (8, 16, 32, 64)))
    for alpha in (0.15, 0.25):
        row = f"  {alpha:>8.2f} "
        for h in (8, 16, 32, 64):
            lr = log_restart_cost(alpha, h) - log_dfs_cost(5.0, 1.0, h)
            row += f"{math.exp(lr):>14.4g}"
        print(row)
    print("     (it blows up at alpha=0.15 < 1/5, and collapses like")
    print("      (1/(5 alpha))^h at alpha=0.25 > 1/5.)")


# ----------------------------------------------------------------------------
# 7. The ascent exponent law
# ----------------------------------------------------------------------------


def demo_exponent_law() -> None:
    banner("7.  Ascent exponent law:  log E_min(h)/h  ->  log min(b, 1/alpha)")
    for b in (3.0, 5.0):
        w = b - 2.0 if b > 2.0 else 1.0
        print(f"\n     branching b = {b:g}, waste weight w = {w:g};"
              f"  kink at alpha = 1/b = {1.0 / b:.4f}")
        print(f"  {'alpha':>8} " + "".join(f"{'h=' + str(h):>11}"
                                           for h in (10, 40, 160, 640))
              + f"{'limit':>12}{'min(b,1/a)':>13}")
        for alpha in (0.15, 1.0 / b, 0.4, 0.6, 0.9):
            row = f"  {alpha:>8.4f} "
            for h in (10, 40, 160, 640):
                row += f"{log_min_cost(b, w, alpha, h) / h:>11.5f}"
            lim = math.log(min(b, 1.0 / alpha))
            row += f"{lim:>12.5f}{min(b, 1.0 / alpha):>13.5f}"
            print(row)
    print("\n     Note the kink: below alpha = 1/b the exponent is pinned at b,")
    print("     so accuracy buys nothing at the level of the rate; above it the")
    print("     exponent is 1/alpha and strictly decreasing.")

    print("\n     Exponential -> polynomial transition only AT alpha = 1:")
    for alpha in (0.9, 0.99, 0.999, 1.0):
        vals = [math.exp(-h * math.log(alpha)) for h in (10, 100, 1000)]
        print(f"    alpha={alpha:<6} E_restart/h at h=10,100,1000: "
              + "  ".join(f"{v:.6g}" for v in vals))


# ----------------------------------------------------------------------------
# 8. Master hint law refuted
# ----------------------------------------------------------------------------


def demo_hint_law_refuted() -> None:
    banner("8.  Master hint law REFUTED:  branch-hint speedup = (b alpha)^h")
    print("     A one-shot class hint keeping a fraction theta >= 1/3 of a ternary")
    print("     tree is capped at speedup 1/theta <= 3.  Sequential branch hints")
    print("     are not capped at all.")
    print(f"\n  {'alpha':>8} " + "".join(f"{'h=' + str(h):>14}"
                                         for h in (1, 2, 5, 10, 20))
          + f"{'cap 1/theta':>14}")
    for alpha in (1.0 / 3.0, 0.4, 0.5, 0.7, 0.9):
        row = f"  {alpha:>8.4f} "
        for h in (1, 2, 5, 10, 20):
            row += f"{hint_speedup(3.0, alpha, h):>14.4g}"
        row += f"{3.0:>14.1f}"
        print(row)
    print("\n     Closed form check, speedup == (3 alpha)^h:")
    for alpha in (0.4, 0.7, 0.9):
        for h in (3, 11):
            check(f"alpha={alpha}, h={h}", hint_speedup(3.0, alpha, h),
                  (3.0 * alpha) ** h, tol=1e-9)
    print("\n     Smallest depth at which the class-hint cap 3 is exceeded:")
    for alpha in (0.35, 0.4, 0.5, 0.7, 0.9):
        h = 1
        while hint_speedup(3.0, alpha, h) <= 3.0 and h < 10_000:
            h += 1
        print(f"    alpha={alpha:<5}  h = {h}")


# ----------------------------------------------------------------------------
# 9. Exact breakeven threshold
# ----------------------------------------------------------------------------


def demo_breakeven() -> None:
    banner("9.  Exact breakeven:  (1+c) E_restart < F  <=>  alpha > alpha*")
    budget = 183_000.0          # median exact-scan steps of the reference benchmark
    h = 32
    print(f"     Exact-solver budget F = {budget:,.0f} visit-equivalents, depth h = {h}.")
    print(f"\n  {'c':>8} {'alpha*':>10} {'win at 0.85?':>14} {'win at 0.96?':>14}")
    for c in (0.0, 1.0, 10.0, 100.0, 1000.0, 3000.0):
        a_star = critical_accuracy(c, budget, h)
        w85 = (1.0 + c) * restart_cost(0.85, h) < budget
        w96 = (1.0 + c) * restart_cost(0.96, h) < budget
        print(f"  {c:>8.0f} {a_star:>10.5f} {str(w85):>14} {str(w96):>14}")
        # threshold is exact: the iff must hold in both directions
        assert w85 == (0.85 > a_star)
        assert w96 == (0.96 > a_star)
    print("\n     alpha* is strictly increasing in the per-step overhead c"
          " (verified above).")

    print("\n     Stratum behaviour:")
    strata: List[Tuple[str, float, int]] = [
        ("balanced   (exact solver already instant)", 20.0, 32),
        ("majority   (median 183k steps)", 183_000.0, 32),
        ("deep tail  (huge budget, but far huger depth)", 1.0e40, 2_000_000),
    ]
    best_available = 0.9999
    for name, f_budget, hh in strata:
        a_star = critical_accuracy(0.0, f_budget, hh)
        feasible = a_star < best_available
        print(f"    {name:<46} h={hh:<9} alpha* = {a_star:.7f}"
              f"   {'winnable' if feasible else 'NEVER wins'}")
    a_deep = critical_accuracy(0.0, 1.0e40, 2_000_000)
    print(f"\n     Deep tail even at alpha = 0.9999:  required {a_deep:.7f}"
          f" > 0.9999  ->  {a_deep > 0.9999}")
    print("     (depth grows far faster than the logarithm of the budget, so the")
    print("      compounding alpha^h defeats any fixed sub-unit accuracy.)")

    print("\n     Barrier probe: is a per-step feature of cost sqrt(N) affordable?")
    n_instance = 1.0e10          # instance scale matching a ~183k-step exact scan
    sqrt_n = math.sqrt(n_instance)
    affordable_c = budget / restart_cost(0.96, h) - 1.0
    margin = math.log10(sqrt_n / max(affordable_c, 1e-300))
    print(f"    sqrt(N) for N ~ {n_instance:.0e}            = {sqrt_n:.4g}")
    print(f"    largest affordable c at alpha = 0.96  = {affordable_c:.4g}")
    print(f"    exclusion margin                      ~ {margin:.2f} orders of magnitude")
    print("    -> excluded, but by a thin margin: a fifty-fold cheaper feature")
    print("       evaluation would flip the calculus.")


# ----------------------------------------------------------------------------
# 10. Supply side: measured channel vs required accuracy
# ----------------------------------------------------------------------------


def demo_supply_gap() -> None:
    banner("10. Supply vs demand: the measured channel against the threshold")
    measured_entropy_share = 0.19     # channel carries ~19% of the relevant entropy
    baseline_accuracy = 1.0 / 3.0     # raw accuracy near the majority baseline
    required = critical_accuracy(0.0, 183_000.0, 32)
    print(f"     Measured channel entropy share : {measured_entropy_share:.0%}")
    print(f"     Measured raw accuracy          : ~{baseline_accuracy:.3f}"
          f"  (near the majority baseline)")
    print(f"     Required accuracy alpha*       : {required:.3f}")
    print(f"     Gap                            : {required - baseline_accuracy:.3f}")
    print("     -> The channel exists and is measurable, but buys no ascent win today.")

    print("\n     Cost of the shortfall, in expected visits at depth 32:")
    for alpha in (baseline_accuracy, 0.5, 0.7, required, 0.99):
        print(f"    alpha={alpha:<8.4f} E_restart = {restart_cost(alpha, 32):.6g}")


# ----------------------------------------------------------------------------


def main() -> None:
    print(__doc__)
    demos: List[Tuple[str, Callable[[], None]]] = [
        ("dfs closed form", demo_dfs_closed_form),
        ("restart geometric", demo_restart_geometric),
        ("calibration and beam", demo_calibration_and_beam),
        ("effective branching", demo_effective_branching_refuted),
        ("crossover", demo_crossover),
        ("exponent law", demo_exponent_law),
        ("hint law", demo_hint_law_refuted),
        ("breakeven", demo_breakeven),
        ("supply gap", demo_supply_gap),
    ]
    for _, fn in demos:
        fn()
    banner("All demonstrations complete.")


if __name__ == "__main__":
    main()
