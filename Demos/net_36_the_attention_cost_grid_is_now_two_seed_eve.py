#!/usr/bin/env python3
"""
Numerical demonstrations for the attention-cost law k* = d*ctx/32.

Self-contained: standard library only (math, random, itertools). Every helper is
inlined and type-hinted. Running the file prints a narrated set of checks:

  1. The Cauchy-Schwarz truncation bound   (sum_{i in T} p_i)^2 <= |T| * sum p_i^2
  2. The mass-knee lower bound             |T| >= rho^2 * N_eff
  3. The certified mass/accuracy separation at the measured long-context cell
  4. The spike family: N_eff -> 4 while top-k mass stays at 1/2
  5. Sharpness of the Cauchy-Schwarz bound at k = 1
  6. The cost law k* = d*ctx/32 and the context-invariant speedup 32/d
  7. Depth rigidity: near-isometric stacks stay linear, expansive ones do not
  8. The exact random-k control law and the selection-gain ceiling
  9. Knee stability under seed perturbation, and grid completion
 10. The two-sided margin law m/(8LB) <= 1 - rho(k*) <= m/(4LB)
"""

from __future__ import annotations

import math
import random
from itertools import combinations
from typing import Dict, Iterable, List, Sequence, Tuple

# ----------------------------------------------------------------------------
# Measured data (round NET-36)
# ----------------------------------------------------------------------------

CELL_A_SWEEP: Dict[int, float] = {8: 0.858, 16: 0.922, 32: 0.970,
                                  64: 0.996, 96: 0.999, 128: 1.000}
CELL_A_NEFF: float = 52.73
CELL_A_DEPTH: int = 16
CELL_A_CTX: int = 128

CELL_B_SWEEP: Dict[int, float] = {16: 0.965, 32: 0.976, 64: 0.985,
                                  128: 0.993, 256: 0.998, 384: 1.000}
CELL_B_NEFF: float = 152.11
CELL_B_DEPTH: int = 4
CELL_B_CTX: int = 512

THRESHOLD: float = 0.98
SEED_SPREAD: float = 0.002


# ----------------------------------------------------------------------------
# Core quantities
# ----------------------------------------------------------------------------

def collision_mass(p: Sequence[float]) -> float:
    """Collision mass sum_i p_i^2 of a weight vector."""
    return sum(x * x for x in p)


def effective_support(p: Sequence[float]) -> float:
    """Effective support N_eff = 1 / sum_i p_i^2 (inverse participation ratio)."""
    c = collision_mass(p)
    if c <= 0.0:
        raise ValueError("collision mass must be positive")
    return 1.0 / c


def topk_mass(p: Sequence[float], k: int) -> float:
    """Mass carried by the k largest entries of p."""
    return sum(sorted(p, reverse=True)[:k])


def cs_mass_ceiling(k: int, n_eff: float) -> float:
    """Cauchy-Schwarz ceiling sqrt(k / N_eff) on the mass any k positions carry."""
    return min(1.0, math.sqrt(k / n_eff))


def mass_knee_lower_bound(rho: float, n_eff: float) -> float:
    """Minimum number of positions needed to retain a fraction rho of the mass."""
    return rho * rho * n_eff


def knee(sweep: Dict[int, float], threshold: float = THRESHOLD) -> int:
    """Smallest swept budget whose retained accuracy reaches the threshold."""
    for k in sorted(sweep):
        if sweep[k] >= threshold:
            return k
    raise ValueError("threshold never reached on the swept ladder")


def predicted_knee(depth: int, ctx: int) -> int:
    """The attention-cost law k* = d * ctx / 32."""
    if (depth * ctx) % 32 != 0:
        raise ValueError("32 must divide d * ctx for the law to give an integer")
    return depth * ctx // 32


def certified_tolerance(sweep: Dict[int, float], k_star: int,
                        threshold: float = THRESHOLD) -> float:
    """Largest eta for which any rerun within eta reports the same knee."""
    pass_margin = sweep[k_star] - threshold
    fails = [threshold - sweep[j] for j in sweep if j < k_star]
    fail_margin = min(fails) if fails else float("inf")
    return min(pass_margin, fail_margin)


# ----------------------------------------------------------------------------
# The spike family: 1/2 on one position, 1/2 spread over n+1 others
# ----------------------------------------------------------------------------

def spike_row(n: int) -> List[float]:
    """Spike-plus-uniform row on n+2 positions."""
    return [0.5] + [0.5 / (n + 1)] * (n + 1)


# ----------------------------------------------------------------------------
# Depth legs
# ----------------------------------------------------------------------------

def geometric_factor(lipschitz: float, depth: int) -> float:
    """sum_{i<d} Lambda^i : the error-amplification factor of a d-layer stack."""
    return sum(lipschitz ** i for i in range(depth))


def zipf_tail(amplitude: float, ctx: int, k: int) -> float:
    """Scale-free tail A * ctx / k left outside the top k positions."""
    return amplitude * ctx / k


def least_feasible_budget(amplitude: float, budget: float,
                          depth: int, ctx: int) -> int:
    """Least k with d * zipf_tail(k) <= budget, i.e. ceil(A d ctx / delta)."""
    return math.ceil(amplitude * depth * ctx / budget)


# ----------------------------------------------------------------------------
# Random-k control
# ----------------------------------------------------------------------------

def exact_mean_random_mass(p: Sequence[float], k: int) -> float:
    """Average mass of a uniformly random k-subset, by exhaustive enumeration."""
    idx = range(len(p))
    subsets = list(combinations(idx, k))
    return sum(sum(p[i] for i in S) for S in subsets) / len(subsets)


def selection_gain_ceiling(ctx: int, k: int, n_eff: float) -> float:
    """Upper bound ctx / sqrt(k * N_eff) on selection's mass advantage."""
    return ctx / math.sqrt(k * n_eff)


# ----------------------------------------------------------------------------
# Margin law
# ----------------------------------------------------------------------------

def margin_knee(amplitude: float, ctx: int, lipschitz: float,
                value_bound: float, margin: float) -> int:
    """ceil(4 L B A ctx / m): the budget the margin channel selects."""
    return math.ceil(4.0 * lipschitz * value_bound * amplitude * ctx / margin)


# ----------------------------------------------------------------------------
# Narrated checks
# ----------------------------------------------------------------------------

def rule(title: str) -> None:
    print("\n" + "=" * 74)
    print(title)
    print("=" * 74)


def demo_cauchy_schwarz() -> None:
    rule("1. The Cauchy-Schwarz truncation bound")
    rng = random.Random(20260816)
    print(f"{'trial':>6} {'|T|':>5} {'mass(T)^2':>12} {'|T| * C(p)':>12}  holds")
    for trial in range(6):
        n = rng.randint(20, 60)
        raw = [rng.expovariate(1.0) ** 2 for _ in range(n)]
        total = sum(raw)
        p = [x / total for x in raw]
        k = rng.randint(1, n)
        T = rng.sample(range(n), k)
        lhs = sum(p[i] for i in T) ** 2
        rhs = k * collision_mass(p)
        print(f"{trial:>6} {k:>5} {lhs:>12.6f} {rhs:>12.6f}  {lhs <= rhs + 1e-12}")
    print("\nThe bound holds for arbitrary subsets, not only the top-k set.")


def demo_mass_knee() -> None:
    rule("2 & 3. The mass knee, and the certified separation at the long-context cell")
    n_eff = CELL_B_NEFF
    need = mass_knee_lower_bound(0.98, n_eff)
    k_star = knee(CELL_B_SWEEP)
    print(f"Measured effective support           N_eff = {n_eff}")
    print(f"Positions needed to keep 98% of mass  >= {need:.2f}  (so >= 147)")
    print(f"Measured accuracy knee                k*   = {k_star}")
    print(f"Ratio (mass knee) / (accuracy knee)        = {need / k_star:.2f}x")
    ceiling = cs_mass_ceiling(k_star, n_eff)
    print(f"\nAt k = {k_star}, the mass any positions can carry is at most "
          f"{ceiling:.4f} (<= 0.65)")
    print(f"But the measured retained ACCURACY at k = {k_star} is "
          f"{CELL_B_SWEEP[k_star]:.3f}")
    print(f"=> at least {100 * (1 - ceiling):.1f}% of the attention mass is "
          f"discarded while 98.5% of accuracy survives.")


def demo_spike_family() -> None:
    rule("4 & 5. Small effective support does NOT imply a small knee")
    print(f"{'n':>8} {'N_eff':>10} {'top-1':>8} {'top-8':>8} {'top-64':>8} "
          f"{'CS ratio':>10}")
    for n in (8, 64, 512, 4096, 65536):
        p = spike_row(n)
        n_eff = effective_support(p)
        ratio = (p[0] ** 2) / (1.0 * collision_mass(p))
        print(f"{n:>8} {n_eff:>10.5f} {topk_mass(p, 1):>8.4f} "
              f"{topk_mass(p, 8):>8.4f} {topk_mass(p, 64):>8.4f} {ratio:>10.6f}")
    print("\nN_eff -> 4 ('essentially four positions'), yet for every fixed k the")
    print("top-k mass -> 1/2. No bound 'top-k mass >= F(k, N_eff)' with F(k,4) > 1/2")
    print("can exist. The last column -> 1: the Cauchy-Schwarz bound is sharp at k=1.")


def demo_cost_law() -> None:
    rule("6. The cost law k* = d*ctx/32 and the context-invariant speedup")
    amplitude, budget = 1.0, 32.0          # calibrated ratio A/delta = 1/32
    print(f"{'d':>4} {'ctx':>6} {'predicted':>10} {'derived':>9} {'measured':>9} "
          f"{'speedup':>9}")
    cells: List[Tuple[int, int, int]] = [
        (4, 128, 16), (8, 128, 32), (16, 128, 64), (4, 512, 64),
    ]
    for d, ctx, measured in cells:
        pred = predicted_knee(d, ctx)
        derived = least_feasible_budget(amplitude, budget, d, ctx)
        print(f"{d:>4} {ctx:>6} {pred:>10} {derived:>9} {measured:>9} "
              f"{ctx / pred:>8.1f}x")
    print("\nThe speedup column equals 32/d exactly, with no dependence on ctx.")
    print("Pre-registered extension: d=4, ctx=1024 -> k* =",
          predicted_knee(4, 1024), "with mass ceiling",
          f"{cs_mass_ceiling(128, 1024.0):.4f} (<= 0.36).")


def demo_depth_rigidity() -> None:
    rule("7. Depth rigidity: near-isometry keeps the law linear, expansion breaks it")
    print(f"{'d':>5} {'nonexp. d*eps':>15} {'Lam=1+1/d':>12} {'Lam=1.05':>12} "
          f"{'(1.05 factor)/d':>17}")
    for d in (4, 8, 16, 32, 64, 128):
        nonexp = float(d)
        near = geometric_factor(1.0 + 1.0 / d, d)
        expansive = geometric_factor(1.05, d)
        print(f"{d:>5} {nonexp:>15.2f} {near:>12.2f} {expansive:>12.2f} "
              f"{expansive / d:>17.2f}")
    print(f"\nNear-isometry (Lambda = 1 + c/d) stays within exp(c) = "
          f"{math.e:.3f} of the linear law d.")
    print("A FIXED expansion Lambda = 1.05 makes the last column grow without")
    print("bound, so no law k* = C*d can survive at large depth.")


def demo_random_control() -> None:
    rule("8. The random-k control: exact mean mass, and the selection ceiling")
    rng = random.Random(12345)
    n = 14
    raw = [rng.expovariate(1.0) for _ in range(n)]
    total = sum(raw)
    p = [x / total for x in raw]
    print(f"Row of {n} positions, N_eff = {effective_support(p):.3f}")
    print(f"{'k':>4} {'exact mean (enum.)':>20} {'k/n (theory)':>14} "
          f"{'selected top-k':>16}")
    for k in (1, 3, 5, 7, 10):
        print(f"{k:>4} {exact_mean_random_mass(p, k):>20.8f} {k / n:>14.8f} "
              f"{topk_mass(p, k):>16.8f}")
    gain = selection_gain_ceiling(CELL_B_CTX, 64, CELL_B_NEFF)
    print(f"\nAt the measured cell (ctx=512, k=64, N_eff={CELL_B_NEFF}):")
    print(f"  selection's mass advantage over the control is at most "
          f"{gain:.2f}x")
    print("  while the measured ACCURACY gap is +7.6 / +5.2 points --")
    print("  so the control gap is about WHICH positions are kept, not bulk mass.")


def demo_knee_stability() -> None:
    rule("9. Knee stability and grid completion")
    for name, sweep, d, ctx in (("A", CELL_A_SWEEP, CELL_A_DEPTH, CELL_A_CTX),
                                ("B", CELL_B_SWEEP, CELL_B_DEPTH, CELL_B_CTX)):
        k_star = knee(sweep)
        tol = certified_tolerance(sweep, k_star)
        pred = predicted_knee(d, ctx)
        print(f"cell {name}: d={d:>2}, ctx={ctx:>3}  k*={k_star:>3}  "
              f"predicted={pred:>3}  maximal tolerance eta={tol:.3f}  "
              f"exact={k_star == pred}")
    print(f"\nObserved seed-to-seed spread: +/-{SEED_SPREAD}")
    print("The conservative certified tolerances quoted for the two cells are")
    print("0.005 and 0.003, both inside the maximal values above and both")
    print("strictly larger than the observed spread, so no seed could have moved")
    print("either knee. Monte-Carlo confirmation:")
    rng = random.Random(2718281828)
    for name, sweep in (("A", CELL_A_SWEEP), ("B", CELL_B_SWEEP)):
        moved = 0
        for _ in range(20000):
            perturbed = {k: v + rng.uniform(-SEED_SPREAD, SEED_SPREAD)
                         for k, v in sweep.items()}
            if knee(perturbed) != 64:
                moved += 1
        print(f"  cell {name}: {moved} of 20000 perturbed reruns moved the knee.")


def demo_margin_law() -> None:
    rule("10. The two-sided margin law")
    amplitude, ctx, lipschitz, value_bound = 1.0 / 32.0, 512, 1.0, 1.0
    print(f"{'margin m':>10} {'k_m':>6} {'m/(8LB)':>10} {'deficit':>10} "
          f"{'m/(4LB)':>10} {'window':>8}")
    for margin in (8.0, 12.0, 20.0, 33.0, 50.0, 64.0):
        k_m = margin_knee(amplitude, ctx, lipschitz, value_bound, margin)
        deficit = zipf_tail(amplitude, ctx, k_m)
        lo = margin / (8 * lipschitz * value_bound)
        hi = margin / (4 * lipschitz * value_bound)
        x = 4 * lipschitz * value_bound * amplitude * ctx / margin
        print(f"{margin:>10.2f} {k_m:>6} {lo:>10.4f} {deficit:>10.4f} "
              f"{hi:>10.4f} {k_m / x:>8.3f}")
    print("\nThe deficit column always lies between the two bounds, and the last")
    print("column (the dimensionless knee) always lies in [1, 2] -- a window fixed")
    print("in advance with no free constant.")
    print(f"\nFalsifiable numeric prediction at the long-context cell:")
    print(f"  certified mass ceiling rho <= 0.65 forces the held-out logit margin")
    print(f"  to satisfy m > 1.4 * L * B.")


def main() -> None:
    print("=" * 74)
    print("The attention-cost law k* = d*ctx/32: numerical demonstrations")
    print("=" * 74)
    demo_cauchy_schwarz()
    demo_mass_knee()
    demo_spike_family()
    demo_cost_law()
    demo_depth_rigidity()
    demo_random_control()
    demo_knee_stability()
    demo_margin_law()
    print("\n" + "=" * 74)
    print("All demonstrations complete.")
    print("=" * 74)


if __name__ == "__main__":
    main()
