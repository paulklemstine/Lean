"""
Numerical demonstrations for
"Selection Gaps, Certification Depth, and the Dilution of Data-Free Attention
Pruning at Long Context".

Self-contained: standard library only (math, itertools, random).  Run with

    python3 demo.py

Every section reproduces one theorem of the paper numerically:

  1. The knee of the measured sweep, its margin, and its exact robustness radius.
  2. Certification depth of the five-rung margin ladder, and its collapse with noise.
  3. The random-k baseline is exactly k/L (brute force over all k-subsets).
  4. Non-negativity of the selection gap, and rigidity at the uniform profile.
  5. Cauchy-Schwarz concentration cap, and the no-bounded-working-set theorem.
  6. Internal consistency check on the reported statistics of the measured cell.
  7. The exchange theorem: T_{2k}(split p) = T_k(p) exactly, including for
     profiles with negative weights (no positivity is used).
  8. Product law <-> constant speedup, and the null probability of an exact chain.
"""

from __future__ import annotations

import math
import random
from itertools import combinations
from typing import Dict, List, Optional, Sequence, Tuple

# --------------------------------------------------------------------------
# The measurement (depth d = 4, context L = 2048, single seed)
# --------------------------------------------------------------------------

BAR: float = 0.98

SWEEP_2048: List[Tuple[int, float]] = [
    (96, 0.939), (128, 0.951), (160, 0.963), (192, 0.970), (224, 0.976),
    (256, 0.9813), (288, 0.984), (384, 0.993), (512, 0.997), (768, 0.996),
    (1024, 0.998),
]

# margins of the five rungs, ctx = 128, 256, 512, 1024, 2048
MARGIN_LADDER: List[float] = [0.007, 0.010, 0.003, 0.006, 0.0013]

INTER_SEED_SPREAD: float = 0.006


# --------------------------------------------------------------------------
# 1.  Knee, margin, robustness radius
# --------------------------------------------------------------------------

def knee(sweep: Sequence[Tuple[int, float]], bar: float) -> Optional[int]:
    """Least budget on the grid whose retained accuracy reaches the bar.

    No monotonicity of the curve is assumed (the measured curve dips).
    """
    for k, retained in sorted(sweep):
        if retained >= bar:
            return k
    return None


def robustness_radius(sweep: Sequence[Tuple[int, float]], bar: float) -> float:
    """Largest eta for which the knee claim survives every eta-perturbation.

    It is the minimum of the margin at the knee and the deficits below it.
    """
    k_star = knee(sweep, bar)
    assert k_star is not None
    margin = dict(sweep)[k_star] - bar
    deficits = [bar - c for k, c in sweep if k < k_star]
    return min([margin] + deficits)


def perturbed_knee(sweep: Sequence[Tuple[int, float]], bar: float,
                   eta: float) -> int:
    """Knee of the measurement shifted uniformly upward by eta.

    Shifting the whole curve is an admissible (monotone) perturbation of size
    eta; it is the perturbation that promotes the lowest grid point.
    """
    shifted = [(k, c + eta) for k, c in sweep]
    k_star = knee(shifted, bar)
    assert k_star is not None
    return k_star


def section_1() -> None:
    print("=" * 74)
    print("1.  Knee, margin, and exact robustness radius at (d=4, ctx=2048)")
    print("=" * 74)
    k_star = knee(SWEEP_2048, BAR)
    margin = dict(SWEEP_2048)[k_star] - BAR
    print(f"  knee k*                 = {k_star}")
    print(f"  product law d*ctx/32    = {4 * 2048 // 32}")
    print(f"  margin at the knee      = {margin:.4f}")
    print(f"  deficit at 224          = {BAR - dict(SWEEP_2048)[224]:.4f}")
    print(f"  robustness radius eta*  = {robustness_radius(SWEEP_2048, BAR):.4f}")
    print(f"  curve monotone?         = "
          f"{all(b >= a for (_, a), (_, b) in zip(SWEEP_2048, SWEEP_2048[1:]))}"
          "   (0.997 at 512 > 0.996 at 768)")
    for eta in (0.0013, 0.002, 0.004, INTER_SEED_SPREAD):
        print(f"  knee under a +{eta:.4f} shift = "
              f"{perturbed_knee(SWEEP_2048, BAR, eta)}")
    print("  -> at the measured inter-seed spread the sweep already reads 224.\n")


# --------------------------------------------------------------------------
# 2.  Certification depth of a margin ladder
# --------------------------------------------------------------------------

def certification_depth(margins: Sequence[float], eta: float) -> int:
    """First rung whose margin falls below the noise level (or the full length)."""
    for i, m in enumerate(margins):
        if not eta <= m:
            return i
    return len(margins)


def section_2() -> None:
    print("=" * 74)
    print("2.  Certification depth: exact at five doublings, certified at two")
    print("=" * 74)
    print(f"  margin ladder = {MARGIN_LADDER}")
    for eta in (0.0013, 0.002, 0.003, 0.004, INTER_SEED_SPREAD, 0.010):
        print(f"  eta = {eta:<7.4f} -> certified depth "
              f"{certification_depth(MARGIN_LADDER, eta)}")
    # antitonicity: more noise never certifies more rungs
    grid = [i / 2000 for i in range(0, 40)]
    depths = [certification_depth(MARGIN_LADDER, e) for e in grid]
    monotone = all(b <= a for a, b in zip(depths, depths[1:]))
    print(f"  depth antitone in the noise over a 40-point grid: {monotone}\n")


# --------------------------------------------------------------------------
# 3.  The random-k baseline is exactly k/L
# --------------------------------------------------------------------------

def mean_subset_mass(profile: Sequence[float], k: int) -> float:
    """Average of the mass of a k-subset, computed by brute force."""
    n = len(profile)
    subsets = list(combinations(range(n), k))
    return sum(sum(profile[i] for i in S) for S in subsets) / len(subsets)


def top_k_mass(profile: Sequence[float], k: int) -> float:
    """Largest mass carried by any k positions (a sort suffices)."""
    return sum(sorted(profile, reverse=True)[:k])


def section_3() -> None:
    print("=" * 74)
    print("3.  The random-k baseline equals k/L exactly (brute force check)")
    print("=" * 74)
    rng = random.Random(20450)
    n = 12
    raw = [rng.random() for _ in range(n)]
    total = sum(raw)
    profile = [x / total for x in raw]
    for k in (1, 3, 6, 9, 12):
        avg = mean_subset_mass(profile, k)
        print(f"  L={n}, k={k:2d}:  mean over all C(L,k) subsets = {avg:.12f}"
              f"   k/L = {k / n:.12f}   |diff| = {abs(avg - k / n):.2e}")
    print()


# --------------------------------------------------------------------------
# 4.  Selection gap: non-negativity and rigidity
# --------------------------------------------------------------------------

def selection_gap(profile: Sequence[float], k: int) -> float:
    """Top-k mass minus the exact random-k baseline k/L."""
    return top_k_mass(profile, k) - k / len(profile)


def section_4() -> None:
    print("=" * 74)
    print("4.  The selection gap is never negative, and vanishes only at uniform")
    print("=" * 74)
    rng = random.Random(451)
    worst = math.inf
    for _ in range(20000):
        n = rng.randint(2, 12)
        raw = [rng.random() ** rng.choice([0.3, 1.0, 4.0]) for _ in range(n)]
        s = sum(raw)
        profile = [x / s for x in raw]
        k = rng.randint(1, n)
        worst = min(worst, selection_gap(profile, k))
    print(f"  minimum gap over 20000 random profiles = {worst:.3e}"
          "  (zero up to floating-point rounding; never negative)")

    uniform = [1 / 8] * 8
    print("  uniform profile on 8 positions:")
    for k in (1, 3, 5, 7):
        print(f"    k={k}: gap = {selection_gap(uniform, k):.1e}"
              "   (exactly zero -- the rigidity point)")

    # a profile a hair away from uniform has a strictly positive gap
    almost = [1 / 8 + (1e-6 if i == 0 else -1e-6 / 7) for i in range(8)]
    print(f"  perturb one entry by 1e-6: gap at k=4 = "
          f"{selection_gap(almost, 4):.3e}  (> 0, as rigidity demands)\n")


# --------------------------------------------------------------------------
# 5.  Concentration: Cauchy-Schwarz cap and no bounded working set
# --------------------------------------------------------------------------

def effective_support(profile: Sequence[float]) -> float:
    """Inverse participation ratio 1 / sum p_i^2."""
    return 1.0 / sum(x * x for x in profile)


def zipf_profile(n: int, alpha: float) -> List[float]:
    """Normalised Zipf-type profile p_i proportional to (i+1)^{-alpha}."""
    raw = [(i + 1) ** (-alpha) for i in range(n)]
    s = sum(raw)
    return [x / s for x in raw]


def section_5() -> None:
    print("=" * 74)
    print("5.  Cauchy-Schwarz cap  T_k^2 <= k / N_eff, and no bounded working set")
    print("=" * 74)
    print(f"  {'L':>7} {'N_eff':>10} {'T_64':>9} {'cap':>9} {'slack':>9}")
    for n in (128, 256, 512, 1024, 2048, 4096):
        p = zipf_profile(n, 0.7)
        neff = effective_support(p)
        t = top_k_mass(p, 64)
        cap = math.sqrt(64 / neff)
        print(f"  {n:7d} {neff:10.2f} {t:9.4f} {cap:9.4f} {cap - t:9.4f}")
    print("  -> the cap is never violated, and N_eff grows without bound,")
    print("     so for any fixed budget the retained mass eventually falls")
    print("     below any target fraction (no bounded working set).")
    p = zipf_profile(2 ** 20, 0.7)
    print(f"  at L = 2^20 the top-64 mass is only {top_k_mass(p, 64):.4f}\n")


# --------------------------------------------------------------------------
# 6.  Internal consistency of the reported statistics
# --------------------------------------------------------------------------

def section_6() -> None:
    print("=" * 74)
    print("6.  Consistency check on the reported statistics at ctx = 2048")
    print("=" * 74)
    reported_neff = 526.39
    for k, mass in ((128, 0.589), (256, 0.731)):
        cap = math.sqrt(k / reported_neff)
        print(f"  reported top-{k:3d} mass = {mass:.3f},  cap sqrt(k/N_eff) "
              f"= {cap:.3f}   -> {'CONSISTENT' if mass <= cap else 'EXCEEDS CAP'}")
    implied = 256 / 0.731 ** 2
    print(f"  a top-256 mass of 0.731 forces an inverse participation ratio")
    print(f"  of at most {implied:.2f} < {reported_neff}, so the reported")
    print("  effective support is a different concentration statistic.")
    print(f"  Read as an IPR, N_eff = {reported_neff} caps the top-256 mass at "
          f"{math.sqrt(256 / reported_neff):.3f} < 0.98:")
    print("  the knee retains accuracy, not attention mass.\n")


# --------------------------------------------------------------------------
# 7.  The exchange theorem
# --------------------------------------------------------------------------

def split_profile(profile: Sequence[float]) -> List[float]:
    """Self-similar refinement: each position becomes two of half the weight."""
    out: List[float] = []
    for x in profile:
        out.extend([x / 2, x / 2])
    return out


def brute_force_top_mass(profile: Sequence[float], k: int) -> float:
    """Maximum over all k-subsets, computed exhaustively (small L only)."""
    return max(sum(profile[i] for i in S)
               for S in combinations(range(len(profile)), k))


def section_7() -> None:
    print("=" * 74)
    print("7.  Exchange theorem:  T_{2k}(split p) = T_k(p)  exactly")
    print("=" * 74)
    rng = random.Random(9)
    print(f"  {'L':>3} {'k':>3} {'T_k(p)':>12} {'T_2k(split p)':>15} {'diff':>10}")
    worst = 0.0
    for _ in range(8):
        n = rng.randint(3, 8)
        k = rng.randint(1, n)
        # signed weights: no positivity is used anywhere in the argument
        profile = [rng.uniform(-1.0, 1.0) for _ in range(n)]
        a = brute_force_top_mass(profile, k)
        b = brute_force_top_mass(split_profile(profile), 2 * k)
        worst = max(worst, abs(a - b))
        print(f"  {n:3d} {k:3d} {a:12.8f} {b:15.8f} {abs(a - b):10.2e}")
    print(f"  maximum discrepancy = {worst:.2e}  (the functional is invariant)")
    print("  Hence the selection gap is invariant too, since 2k/(2L) = k/L,")
    print("  so ANY measured change of the gap across a doubling refutes")
    print("  exact self-similarity of the profile.\n")

    # the fractional relaxation really is available, and really buys nothing
    p = [0.5, 0.3, 0.2]
    sp = split_profile(p)
    best_paired = brute_force_top_mass(p, 1)
    best_free = brute_force_top_mass(sp, 2)
    mixed = sp[0] + sp[2]          # one half of position 0, one half of position 1
    print(f"  example p = {p}: best paired choice = {best_paired:.3f},")
    print(f"  best free choice of 2 halves = {best_free:.3f}, a mixed choice "
          f"gives {mixed:.3f} <= {best_paired:.3f}.\n")


# --------------------------------------------------------------------------
# 8.  Deployment reading and the null model
# --------------------------------------------------------------------------

def product_law_budget(depth: int, ctx: int) -> float:
    return depth * ctx / 32


def speedup(ctx: int, k: float) -> float:
    return ctx / k


def section_8() -> None:
    print("=" * 74)
    print("8.  Product law = constant speedup; null probability of a chain")
    print("=" * 74)
    print(f"  {'ctx':>6} {'k* = d*ctx/32':>15} {'speedup ctx/k*':>16}")
    for ctx in (128, 256, 512, 1024, 2048):
        k = product_law_budget(4, ctx)
        print(f"  {ctx:6d} {k:15.0f} {speedup(ctx, k):16.2f}")
    print("  -> the speedup is the context-independent constant 32/d = 8.")
    print(f"  alternative reading k = 224: speedup = {speedup(2048, 224):.4f}"
          f"  (= 64/7, not 10.3; the gap exceeds "
          f"{10.3 - speedup(2048, 224):.2f})")
    print("  null probability of an exact n-rung chain (fair one-step coin):")
    for n in (1, 2, 3, 4, 5, 6):
        print(f"    n = {n}:  2^-n = {2.0 ** -n:.5f}"
              f"{'   < 0.05' if 2.0 ** -n < 0.05 else ''}")
    print()


def main() -> None:
    section_1()
    section_2()
    section_3()
    section_4()
    section_5()
    section_6()
    section_7()
    section_8()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
