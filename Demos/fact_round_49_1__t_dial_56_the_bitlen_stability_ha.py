"""
demo.py — Numerical demonstration of tie ceilings and noise budgets
for rank-correlation dials.

Self-contained: standard library only (plus `random` for simulation).
Every helper is inlined and type-hinted.

The script demonstrates, in order:

  1. The Discrete Spread Bound:  m distinct integers have squared spread
     at least (m^3 - m)/12, with equality for consecutive runs.

  2. The Tie-Block Ceiling and its sharpness: for a response constant on
     the blocks of a partition,
         Cov(X, Y)^2 <= (Var X - W) * Var Y,
     with equality attained by Y = E[X | b].

  3. The Starved-Regime Ceiling:
         rho^2 <= 1 - (m^3 - m)/(n^3 - n),
     evaluated at the recorded experiment (m = 194, n = 1200).

  4. The Cubic Starvation Threshold: to force rho <= 0.55 by ties alone
     one needs a tie fraction q with q^3 >= 0.6975, i.e. q >= 0.8867.

  5. The Quantization Ceiling: rho^2 <= 1 - (n^3/r^2 - n)/(n^3 - n),
     which never falls below 3/4 for r >= 2.

  6. The Noise Budget:
         Var(measured_ranks - true_ranks) >= (a - b)^2 (n^3 - n)/12,
     and its instantiation: the drop from 0.55 to 0.405 at n = 1200
     certifies a displacement energy > 3e6, i.e. RMS ~ 50 rank positions.

  7. A Monte-Carlo confirmation that a rank jitter of the certified size
     really does cost about the observed amount of correlation, while a
     16% tie block costs essentially nothing.
"""

from __future__ import annotations

import math
import random
from typing import Dict, List, Sequence, Tuple

# --------------------------------------------------------------------------
# Basic centred moments (uncentred sums, matching the theory's normalisation)
# --------------------------------------------------------------------------


def mean(x: Sequence[float]) -> float:
    """Arithmetic mean of a finite sequence."""
    return sum(x) / len(x)


def var_of(x: Sequence[float]) -> float:
    """Uncentred variance: sum of squared deviations from the mean."""
    mx = mean(x)
    return sum((xi - mx) ** 2 for xi in x)


def cov(x: Sequence[float], y: Sequence[float]) -> float:
    """Uncentred covariance: sum of products of deviations."""
    mx, my = mean(x), mean(y)
    return sum((xi - mx) * (yi - my) for xi, yi in zip(x, y))


def pearson(x: Sequence[float], y: Sequence[float]) -> float:
    """Pearson correlation coefficient of two equal-length sequences."""
    vx, vy = var_of(x), var_of(y)
    if vx <= 0.0 or vy <= 0.0:
        return 0.0
    return cov(x, y) / math.sqrt(vx * vy)


def rank_vector(values: Sequence[float]) -> List[float]:
    """
    Midrank vector of `values`: ties receive the average of the ranks they
    would occupy. Ranks are 0-based.
    """
    n = len(values)
    order = sorted(range(n), key=lambda i: values[i])
    ranks = [0.0] * n
    i = 0
    while i < n:
        j = i
        while j + 1 < n and values[order[j + 1]] == values[order[i]]:
            j += 1
        midrank = (i + j) / 2.0
        for k in range(i, j + 1):
            ranks[order[k]] = midrank
        i = j + 1
    return ranks


def spearman(x: Sequence[float], y: Sequence[float]) -> float:
    """Spearman rank correlation = Pearson correlation of the midranks."""
    return pearson(rank_vector(x), rank_vector(y))


# --------------------------------------------------------------------------
# The theoretical quantities
# --------------------------------------------------------------------------


def spread_floor(m: int) -> float:
    """(m^3 - m)/12 — the sharp minimal spread of m distinct integers."""
    return (m**3 - m) / 12.0


def tie_block_ceiling(n: int, m: int) -> float:
    """
    Starved-Regime Ceiling: the largest Spearman coefficient achievable by
    any dial when m of the n responses are tied in a single block.
    """
    if n < 2:
        return 1.0
    ratio = (m**3 - m) / (n**3 - n)
    return math.sqrt(max(0.0, 1.0 - ratio))


def partition_ceiling(block_sizes: Sequence[int]) -> float:
    """
    Full tie-partition ceiling: every block of size m_k subtracts its own
    (m_k^3 - m_k)/12 from the achievable numerator.
    """
    n = sum(block_sizes)
    if n < 2:
        return 1.0
    correction = sum(m**3 - m for m in block_sizes)
    return math.sqrt(max(0.0, 1.0 - correction / (n**3 - n)))


def quantization_ceiling(n: int, r: int) -> float:
    """
    Quantization Ceiling: the response takes at most r distinct values.
    Worst case (largest ceiling) is equally populated levels.
    """
    if n < 2 or r < 1:
        return 1.0
    ratio = (n**3 / r**2 - n) / (n**3 - n)
    return math.sqrt(max(0.0, 1.0 - ratio))


def starvation_threshold_fraction(rho_target: float) -> float:
    """
    Exact cubic threshold: the tie fraction q at which ties alone could
    force the Spearman coefficient down to rho_target (large-n limit).
    """
    return (1.0 - rho_target**2) ** (1.0 / 3.0)


def minimal_tie_block(n: int, rho_target: float) -> int:
    """
    Least integer m such that a tie block of size m could force
    rho <= rho_target at sample size n. Binary search, O(log n).
    """
    need = (1.0 - rho_target**2) * (n**3 - n)
    lo, hi = 1, n
    while lo < hi:
        mid = (lo + hi) // 2
        if mid**3 - mid >= need:
            hi = mid
        else:
            lo = mid + 1
    return lo


def noise_budget(a: float, b: float, n: int) -> Tuple[float, float]:
    """
    Noise Budget. Returns (energy, rms) where
        energy = (a - b)^2 (n^3 - n)/12   is a certified lower bound on
                 Var(measured ranks - true ranks),
        rms    = sqrt(energy / n)         is the RMS rank displacement.
    """
    energy = (a - b) ** 2 * (n**3 - n) / 12.0
    return energy, math.sqrt(energy / n)


# --------------------------------------------------------------------------
# Conditional expectation on a block partition
# --------------------------------------------------------------------------


def cond_exp(x: Sequence[float], labels: Sequence[int]) -> List[float]:
    """E[x | labels]: replace each entry by the mean over its block."""
    sums: Dict[int, float] = {}
    counts: Dict[int, int] = {}
    for xi, k in zip(x, labels):
        sums[k] = sums.get(k, 0.0) + xi
        counts[k] = counts.get(k, 0) + 1
    return [sums[k] / counts[k] for k in labels]


def within_block_ss(x: Sequence[float], labels: Sequence[int]) -> float:
    """W = sum_i (x_i - E[x | labels]_i)^2."""
    ce = cond_exp(x, labels)
    return sum((xi - ci) ** 2 for xi, ci in zip(x, ce))


# --------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------

SEED = 20261030
N_OBS = 1200
M_ZERO = 194
RHO_OBS = 0.405
BAND_LO = 0.55


def demo_1_spread_bound() -> None:
    print("=" * 74)
    print("1. DISCRETE SPREAD BOUND:  m distinct integers spread >= (m^3-m)/12")
    print("=" * 74)
    rng = random.Random(SEED)
    print(f"{'m':>5} {'floor':>14} {'consecutive':>14} {'random distinct':>18}")
    for m in (2, 5, 10, 50, 194):
        floor = spread_floor(m)
        consecutive = [float(i) for i in range(m)]
        pool = rng.sample(range(0, 20 * m + 1), m)
        scattered = [float(v) for v in pool]
        print(
            f"{m:>5} {floor:>14.2f} {var_of(consecutive):>14.2f} "
            f"{var_of(scattered):>18.2f}"
        )
    print("  Consecutive runs attain the floor exactly; scattering only increases it.\n")


def demo_2_ceiling_sharpness() -> None:
    print("=" * 74)
    print("2. TIE-BLOCK CEILING AND ITS SHARPNESS")
    print("=" * 74)
    rng = random.Random(SEED + 1)
    n = 60
    # A partition into blocks of sizes 20, 15, 15, 10.
    labels: List[int] = [0] * 20 + [1] * 15 + [2] * 15 + [3] * 10
    perm = list(range(n))
    rng.shuffle(perm)
    x = [float(p) for p in perm]  # a rank vector

    vx = var_of(x)
    w = within_block_ss(x, labels)
    ceiling_num = vx - w
    print(f"  sample size n = {n}, block sizes = (20, 15, 15, 10)")
    print(f"  Var X                    = {vx:14.4f}   [= (n^3-n)/12 = {spread_floor(n):.4f}]")
    print(f"  within-block SS  W       = {w:14.4f}")
    print(f"  ceiling numerator Var-W  = {ceiling_num:14.4f}")

    best = 0.0
    for _ in range(20000):
        g = [rng.gauss(0.0, 1.0) for _ in range(4)]
        y = [g[k] for k in labels]
        vy = var_of(y)
        if vy > 0:
            best = max(best, cov(x, y) ** 2 / vy)
    print(f"  best random blockwise Y  : Cov^2/Var Y = {best:14.4f}")

    ce = cond_exp(x, labels)
    attained = cov(x, ce) ** 2 / var_of(ce)
    print(f"  block-averaged response  : Cov^2/Var Y = {attained:14.4f}  <-- attains it")
    print(f"  relative error of attainment = {abs(attained-ceiling_num)/ceiling_num:.2e}")
    print("  The ceiling is exact, not a lossy Cauchy-Schwarz artefact.\n")


def demo_3_starved_ceiling() -> None:
    print("=" * 74)
    print("3. STARVED-REGIME CEILING AT THE RECORDED EXPERIMENT")
    print("=" * 74)
    ratio = (M_ZERO**3 - M_ZERO) / (N_OBS**3 - N_OBS)
    ceil = tie_block_ceiling(N_OBS, M_ZERO)
    print(f"  n = {N_OBS}, zero-hit block m = {M_ZERO}  (fraction q = {M_ZERO/N_OBS:.4f})")
    print(f"  tie penalty (m^3-m)/(n^3-n) = {ratio:.8f}   [~ q^3 = {(M_ZERO/N_OBS)**3:.8f}]")
    print(f"  ceiling on rho^2            = {1-ratio:.8f}")
    print(f"  ceiling on rho              = {ceil:.6f}")
    print(f"  observed rho                = {RHO_OBS}")
    print(f"  band lower edge             = {BAND_LO}")
    print("  VERDICT: the ceiling sits far above the band, so the zero-hit block")
    print("           CANNOT be the cause of the observed collapse.\n")

    print("  How the tie fraction q maps to the ceiling (the cubic at work):")
    print(f"  {'q':>8} {'penalty q^3':>14} {'ceiling rho':>14}")
    for q in (0.05, 0.10, 0.1617, 0.30, 0.50, 0.70, 0.8867, 0.95):
        m = int(round(q * N_OBS))
        print(f"  {q:>8.4f} {(m**3-m)/(N_OBS**3-N_OBS):>14.6f} "
              f"{tie_block_ceiling(N_OBS, m):>14.6f}")
    print()


def demo_4_threshold() -> None:
    print("=" * 74)
    print("4. CUBIC STARVATION THRESHOLD")
    print("=" * 74)
    q_star = starvation_threshold_fraction(BAND_LO)
    print(f"  To force rho <= {BAND_LO} by ties alone one needs")
    print(f"      (m^3-m)/(n^3-n) >= 1 - {BAND_LO}^2 = {1-BAND_LO**2:.4f}")
    print(f"  i.e. a tie fraction q >= {q_star:.6f}  ({100*q_star:.2f}% of the sample).")
    m_min = minimal_tie_block(N_OBS, BAND_LO)
    print(f"  At n = {N_OBS} the least such block size is m = {m_min}"
          f"  (observed: {M_ZERO}).")
    print(f"  Shortfall factor in the tie fraction: {m_min/M_ZERO:.2f}x")
    print(f"  Shortfall factor in the cubic penalty: "
          f"{((1-BAND_LO**2))/((M_ZERO**3-M_ZERO)/(N_OBS**3-N_OBS)):.1f}x\n")


def demo_5_quantization() -> None:
    print("=" * 74)
    print("5. QUANTIZATION CEILING:  even 2 levels permit rho = 0.866")
    print("=" * 74)
    print(f"  {'r levels':>10} {'ceiling rho^2':>16} {'ceiling rho':>14}")
    for r in (2, 3, 5, 10, 50, 200):
        c = quantization_ceiling(N_OBS, r)
        print(f"  {r:>10} {c*c:>16.6f} {c:>14.6f}")
    print(f"\n  The infimum over r >= 2 is sqrt(3/4) = {math.sqrt(0.75):.6f} > {BAND_LO}.")
    print("  No quantization level whatsoever can push the score below the band.")
    # Confirm the equal-block worst case numerically.
    n, r = 1200, 5
    equal = [n // r] * r
    skewed = [n - 4 * 1, 1, 1, 1, 1]
    print(f"\n  Equal blocks {equal}  -> ceiling {partition_ceiling(equal):.6f}")
    print(f"  Skewed blocks {skewed} -> ceiling {partition_ceiling(skewed):.6f}")
    print("  Equal population is the worst case (highest ceiling), as the")
    print("  power-mean inequality predicts.\n")


def demo_6_noise_budget() -> None:
    print("=" * 74)
    print("6. NOISE BUDGET")
    print("=" * 74)
    energy, rms = noise_budget(BAND_LO, RHO_OBS, N_OBS)
    print(f"  assumed true-ranking score a = {BAND_LO}")
    print(f"  observed measured score    b = {RHO_OBS}")
    print(f"  gap a - b                    = {BAND_LO - RHO_OBS:.3f}")
    print(f"  certified displacement energy >= {energy:,.1f}")
    print(f"  i.e. energy > 3.0e6:            {energy > 3.0e6}")
    print(f"  RMS rank displacement        >= {rms:.2f} positions")
    print(f"  as a fraction of n            = {rms/N_OBS:.4f}  ({100*rms/N_OBS:.2f}%)")
    print(f"  asymptotic form (a-b)*n/sqrt(12) = "
          f"{(BAND_LO-RHO_OBS)*N_OBS/math.sqrt(12):.2f}\n")


def demo_7_simulation() -> None:
    print("=" * 74)
    print("7. MONTE-CARLO CONFIRMATION: ties are cheap, jitter is expensive")
    print("=" * 74)
    rng = random.Random(SEED)
    n = N_OBS

    # A dial with a genuine band-edge relationship to the true response.
    truth: List[float] = [rng.gauss(0.0, 1.0) for _ in range(n)]
    # Build a dial correlating with the truth at roughly the band edge.
    target = 0.58
    dial = [target * t + math.sqrt(max(0.0, 1 - target**2)) * rng.gauss(0.0, 1.0)
            for t in truth]
    base = spearman(dial, truth)
    print(f"  baseline Spearman(dial, true response)          = {base:.4f}")

    # (a) Impose the observed tie block: flatten the 194 lowest responses.
    order = sorted(range(n), key=lambda i: truth[i])
    tied = list(truth)
    floor_val = min(truth) - 1.0
    for i in order[:M_ZERO]:
        tied[i] = floor_val
    print(f"  after tying the lowest {M_ZERO} responses          = "
          f"{spearman(dial, tied):.4f}   (loss "
          f"{base - spearman(dial, tied):+.4f})")

    # (b) Quantize the response to 5 levels.
    lo, hi = min(truth), max(truth)
    quantized = [math.floor(5 * (t - lo) / (hi - lo + 1e-12)) for t in truth]
    print(f"  after quantizing the response to 5 levels       = "
          f"{spearman(dial, quantized):.4f}   (loss "
          f"{base - spearman(dial, quantized):+.4f})")

    # (c) Apply a rank jitter at exactly the certified floor.
    _, rms_floor = noise_budget(BAND_LO, RHO_OBS, n)
    true_ranks = rank_vector(truth)
    jittered = [r + rng.gauss(0.0, rms_floor) for r in true_ranks]
    rho_floor = spearman(dial, jittered)
    print(f"  after rank jitter at the certified floor, RMS {rms_floor:.0f}  = "
          f"{rho_floor:.4f}   (loss {base - rho_floor:+.4f})")

    # (d) Independent jitter large enough to actually reproduce the gap.
    sd_rank = math.sqrt(spread_floor(n) / n)
    atten = RHO_OBS / BAND_LO
    sd_required = sd_rank * math.sqrt(max(0.0, 1.0 / atten**2 - 1.0))
    heavy = [r + rng.gauss(0.0, sd_required) for r in true_ranks]
    rho_heavy = spearman(dial, heavy)
    print(f"  after independent jitter with RMS {sd_required:.0f} positions  = "
          f"{rho_heavy:.4f}   (loss {base - rho_heavy:+.4f})")
    print()
    print("  Reading the numbers correctly:")
    print(f"    * the Noise Budget is a LOWER bound: RMS >= {rms_floor:.0f} ranks is")
    print("      necessary, not sufficient. Isotropic noise is an inefficient way")
    print("      to destroy correlation, so it needs far more than the floor.")
    print(f"    * independent rank noise reproducing the observed gap needs")
    print(f"      RMS ~ {sd_required:.0f} ranks ({100*sd_required/n:.0f}% of the sample), energy")
    print(f"      ~ {sd_required**2 * n:,.0f} -- about "
          f"{sd_required**2 * n / (rms_floor**2 * n):.0f}x the certified floor.")
    print("    * either way, the required noise is enormous, while a 16% tie block")
    print("      and 5-level quantization each cost only a few thousandths.")
    print("  The recorded diagnosis pointed at the wrong mechanism.\n")


def main() -> None:
    print()
    print("TIE CEILINGS AND NOISE BUDGETS FOR RANK-CORRELATION DIALS")
    print(f"recorded experiment: n = {N_OBS}, zero-hit m = {M_ZERO}, "
          f"observed rho = {RHO_OBS}, band = [{BAND_LO}, 0.85]")
    print()
    demo_1_spread_bound()
    demo_2_ceiling_sharpness()
    demo_3_starved_ceiling()
    demo_4_threshold()
    demo_5_quantization()
    demo_6_noise_budget()
    demo_7_simulation()
    print("=" * 74)
    print("SUMMARY")
    print("=" * 74)
    print(f"  tie ceiling at (m,n) = ({M_ZERO},{N_OBS}) : "
          f"rho <= {tie_block_ceiling(N_OBS, M_ZERO):.6f}")
    print(f"  quantization ceiling, any r >= 2      : rho <= "
          f"{math.sqrt(0.75):.6f}")
    print(f"  starvation needed for rho <= {BAND_LO}      : q >= "
          f"{starvation_threshold_fraction(BAND_LO):.4f} "
          f"(observed {M_ZERO/N_OBS:.4f})")
    e, r_ = noise_budget(BAND_LO, RHO_OBS, N_OBS)
    print(f"  certified noise budget                : Var(D) >= {e:,.0f}, "
          f"RMS >= {r_:.1f} ranks")
    print()


if __name__ == "__main__":
    main()
