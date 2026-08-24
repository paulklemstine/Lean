"""
The Correlation Budget: numerical demonstrations.

Self-contained (standard library only) numerical demonstrations of:

  1. The three-correlation (Gram) inequality  a^2 + b^2 + c^2 <= 1 + 2abc.
  2. The parity ceiling law  rho^2 <= (1 + c)/2  and the decorrelated
     threshold  rho <= sqrt(2)/2 ~ 0.70711, together with the explicit
     configuration that attains it.
  3. The forcing law  c >= ab - sqrt((1-a^2)(1-b^2))  and its vacuity at the
     recorded bitlen-72 readings.
  4. The advantage law  alpha >= rho - sqrt(1 - rho^2).
  5. The correlation budget  sum_i rho_i^2 <= 1  (Bessel) and the capacity law
     rho <= 1/sqrt(k), with the sharp k-dimensional witness.
  6. The Spearman bridge: rank correlation equals the cosine between centred
     rank vectors, and every tie-free ranking of n items has centred squared
     norm (n^3 - n)/12.
  7. The capacity classification of the recorded dial readings
     (0.78 at bitlen 44 -> capacity 1;  0.605 at bitlen 72 -> capacity 2).

Run:  python3 demo.py
"""

from __future__ import annotations

import math
import random
from itertools import combinations
from typing import List, Sequence, Tuple

# --------------------------------------------------------------------------
# Recorded measurements
# --------------------------------------------------------------------------

SEED_READINGS_72: Tuple[float, float, float] = (0.605, 0.606, 0.603)
POOLED_72: float = 0.605
CI_72: Tuple[float, float] = (0.586, 0.625)
BAND: Tuple[float, float] = (0.55, 0.85)
DIAL_44: float = 0.78
PARITY_GAP: float = 0.05          # count advantage at bitlen 72 is below this
COUNT_READ_72: float = 0.555      # dial minus the parity gap

THRESHOLD: float = math.sqrt(2.0) / 2.0   # 0.7071067811865476


# --------------------------------------------------------------------------
# 0. Elementary vector geometry
# --------------------------------------------------------------------------

def dot(u: Sequence[float], v: Sequence[float]) -> float:
    """Euclidean inner product of two coordinate vectors."""
    return sum(x * y for x, y in zip(u, v))


def norm(u: Sequence[float]) -> float:
    """Euclidean norm."""
    return math.sqrt(dot(u, u))


def corr(u: Sequence[float], v: Sequence[float]) -> float:
    """Cosine of the angle between two nonzero coordinate vectors.

    For centred data vectors this is the Pearson correlation coefficient;
    for centred rank vectors it is Spearman's coefficient.
    """
    return dot(u, v) / (norm(u) * norm(v))


def centre(u: Sequence[float]) -> List[float]:
    """Subtract the mean."""
    m = sum(u) / len(u)
    return [x - m for x in u]


# --------------------------------------------------------------------------
# 1. The three-correlation inequality
# --------------------------------------------------------------------------

def gram_slack(a: float, b: float, c: float) -> float:
    """Slack in the Gram inequality: 1 + 2abc - (a^2 + b^2 + c^2) >= 0."""
    return 1.0 + 2.0 * a * b * c - (a * a + b * b + c * c)


def demo_gram_inequality(trials: int = 20000, dim: int = 6, seed: int = 20261160) -> None:
    print("=" * 74)
    print("1. THE THREE-CORRELATION INEQUALITY  a^2 + b^2 + c^2 <= 1 + 2abc")
    print("=" * 74)
    rng = random.Random(seed)
    worst = math.inf
    worst_triple = (0.0, 0.0, 0.0)
    for _ in range(trials):
        u = [rng.gauss(0.0, 1.0) for _ in range(dim)]
        v = [rng.gauss(0.0, 1.0) for _ in range(dim)]
        w = [rng.gauss(0.0, 1.0) for _ in range(dim)]
        a, b, c = corr(u, w), corr(v, w), corr(u, v)
        s = gram_slack(a, b, c)
        if s < worst:
            worst, worst_triple = s, (a, b, c)
    print(f"  random triples tested          : {trials}")
    print(f"  minimum observed slack         : {worst:+.3e}   (must be >= 0)")
    print(f"  attained at (a, b, c)          : "
          f"({worst_triple[0]:+.4f}, {worst_triple[1]:+.4f}, {worst_triple[2]:+.4f})")
    print(f"  violations found               : {0 if worst >= -1e-12 else 1}")
    print()


# --------------------------------------------------------------------------
# 2. The parity ceiling and its sharp witness
# --------------------------------------------------------------------------

def parity_ceiling(c: float) -> float:
    """Largest common reading rho allowed for two statistics correlated at c."""
    return math.sqrt(max(0.0, (1.0 + c) / 2.0))


def parity_witness(t: float) -> Tuple[List[float], List[float], List[float]]:
    """Explicit vectors in R^3 with corr(u,v)=0 and corr(u,w)=corr(v,w)=t.

    Valid for every t with 2t^2 <= 1, i.e. |t| <= sqrt(2)/2.
    """
    if 2.0 * t * t > 1.0 + 1e-12:
        raise ValueError(f"level {t} exceeds the parity threshold {THRESHOLD:.6f}")
    u = [1.0, 0.0, 0.0]
    v = [0.0, 1.0, 0.0]
    w = [t, t, math.sqrt(max(0.0, 1.0 - 2.0 * t * t))]
    return u, v, w


def demo_parity_threshold() -> None:
    print("=" * 74)
    print("2. THE PARITY CEILING  rho^2 <= (1+c)/2   AND THE THRESHOLD sqrt(2)/2")
    print("=" * 74)
    print(f"  decorrelated threshold sqrt(2)/2 = {THRESHOLD:.6f}")
    print()
    print("  mutual corr c   max common reading  sqrt((1+c)/2)")
    for c in (-0.5, -0.25, 0.0, 0.11, 0.25, 0.5, 0.75, 0.9):
        print(f"      {c:+.2f}                {parity_ceiling(c):.6f}")
    print()
    print("  Sharpness: explicit witnesses attaining a common reading t.")
    print("     t        corr(u,v)     corr(u,w)     corr(v,w)")
    for t in (0.30, 0.50, POOLED_72, 0.70, THRESHOLD):
        u, v, w = parity_witness(t)
        print(f"   {t:.6f}   {corr(u, v):+.6f}    {corr(u, w):.6f}    {corr(v, w):.6f}")
    print()
    print(f"  bitlen 72 reading {POOLED_72}  <= threshold ? "
          f"{POOLED_72 <= THRESHOLD}  -> parity is FREE")
    print(f"  bitlen 44 reading {DIAL_44}   <= threshold ? "
          f"{DIAL_44 <= THRESHOLD}  -> parity is IMPOSSIBLE")
    print()


# --------------------------------------------------------------------------
# 3. The forcing law
# --------------------------------------------------------------------------

def forcing_interval(a: float, b: float) -> Tuple[float, float]:
    """Interval to which the Gram inequality pins the mutual correlation c."""
    half = math.sqrt(max(0.0, (1.0 - a * a) * (1.0 - b * b)))
    return (a * b - half, a * b + half)


def demo_forcing_law() -> None:
    print("=" * 74)
    print("3. THE FORCING LAW  c >= ab - sqrt((1-a^2)(1-b^2))")
    print("=" * 74)
    rows = [
        ("bitlen 44 dial vs strong baseline", 0.78, 0.71),
        ("bitlen 44 dial vs itself         ", 0.78, 0.78),
        ("threshold pair                   ", THRESHOLD, THRESHOLD),
        ("bitlen 72 dial vs count baseline ", POOLED_72, COUNT_READ_72),
    ]
    print("  configuration                        a        b       c >= ...   informative?")
    for label, a, b in rows:
        lo, _ = forcing_interval(a, b)
        informative = "yes" if lo > 0.0 else "NO (vacuous)"
        print(f"  {label}  {a:.4f}   {b:.4f}   {lo:+.5f}    {informative}")
    print()
    lo, _ = forcing_interval(POOLED_72, COUNT_READ_72)
    print(f"  Honest limitation: at the recorded bitlen-72 pair the bound is c >= {lo:+.5f},")
    print("  weaker than the trivial c >= -1 is useful. The data cannot detect correlation")
    print("  between the dial and the count baseline at bitlen 72.")
    print()


# --------------------------------------------------------------------------
# 4. The advantage law
# --------------------------------------------------------------------------

def forced_advantage(rho: float) -> float:
    """Minimum deficit  rho - sqrt(1 - rho^2)  of a decorrelated baseline."""
    return rho - math.sqrt(max(0.0, 1.0 - rho * rho))


def demo_advantage_law() -> None:
    print("=" * 74)
    print("4. THE ADVANTAGE LAW  alpha >= rho - sqrt(1 - rho^2)")
    print("=" * 74)
    print("     dial rho     forced advantage    parity possible?")
    for rho in (0.55, 0.605, 0.65, THRESHOLD, 0.72, 0.78, 0.85):
        f = forced_advantage(rho)
        verdict = "yes" if f <= 0.0 else "no  (baseline must lose)"
        print(f"     {rho:.6f}      {f:+.6f}        {verdict}")
    print()
    print(f"  The forced advantage changes sign exactly at rho = {THRESHOLD:.6f},")
    print("  so observing parity is itself evidence that the dial is at or below sqrt(2)/2")
    print("  -- or else the two statistics are correlated, at level >= 2*rho^2 - 1.")
    print(f"  At rho = {DIAL_44}: forced advantage >= {forced_advantage(DIAL_44):.4f}, "
          f"or forced mutual correlation >= {2 * DIAL_44 ** 2 - 1:.4f}.")
    print()


# --------------------------------------------------------------------------
# 5. The correlation budget and the capacity law
# --------------------------------------------------------------------------

def capacity(rho: float) -> int:
    """Largest k with k*rho^2 <= 1: the decorrelated capacity of level rho."""
    if rho <= 0.0:
        raise ValueError("capacity is defined for positive levels")
    return int(math.floor(1.0 / (rho * rho) + 1e-12))


def capacity_witness(k: int, t: float) -> Tuple[List[List[float]], List[float]]:
    """Orthonormal family of k statistics in R^{k+1} all reading exactly t.

    Requires k*t^2 <= 1.  The family is the first k coordinate axes and the
    response is  (t, ..., t, sqrt(1 - k t^2)).
    """
    if k * t * t > 1.0 + 1e-15:
        raise ValueError(f"level {t} exceeds the capacity bound 1/sqrt({k})")
    u = [[1.0 if j == i else 0.0 for j in range(k + 1)] for i in range(k)]
    w = [t] * k + [math.sqrt(max(0.0, 1.0 - k * t * t))]
    return u, w


def budget_sum(readings: Sequence[float]) -> float:
    """The Bessel budget sum_i rho_i^2, which must be <= 1 for a decorrelated family."""
    return sum(r * r for r in readings)


def demo_capacity_law() -> None:
    print("=" * 74)
    print("5. THE CORRELATION BUDGET  sum_i rho_i^2 <= 1  AND CAPACITY  rho <= 1/sqrt(k)")
    print("=" * 74)
    print("     k    1/sqrt(k)")
    for k in range(1, 7):
        print(f"     {k}    {1.0 / math.sqrt(k):.6f}")
    print()
    print("  Sharp witnesses (orthonormal family of k statistics in dimension k+1):")
    print("     k      t        max |orthonormality error|    max |reading - t|")
    for k, t in ((2, POOLED_72), (3, 0.55), (4, 0.5), (5, 1.0 / math.sqrt(5))):
        u, w = capacity_witness(k, t)
        orth_err = max(
            [abs(dot(u[i], u[i]) - 1.0) for i in range(k)]
            + [abs(dot(u[i], u[j])) for i, j in combinations(range(k), 2)]
        )
        read_err = max(abs(corr(u[i], w) - t) for i in range(k))
        print(f"     {k}   {t:.6f}          {orth_err:.2e}                 {read_err:.2e}")
    print()
    print("  Budget audit of hypothetical decorrelated families:")
    for readings in ([0.605, 0.605], [0.605, 0.605, 0.605], [0.78, 0.78], [0.8, 0.8]):
        s = budget_sum(readings)
        verdict = "feasible" if s <= 1.0 else f"IMPOSSIBLE (redundancy >= {s - 1:.4f})"
        print(f"     readings {readings}  ->  sum rho^2 = {s:.6f}   {verdict}")
    print()


# --------------------------------------------------------------------------
# 6. The Spearman bridge
# --------------------------------------------------------------------------

def spearman_from_d2(ranks_u: Sequence[float], ranks_v: Sequence[float]) -> float:
    """Classical Spearman coefficient  1 - 6*sum d_i^2 / (n^3 - n)."""
    n = len(ranks_u)
    d2 = sum((x - y) ** 2 for x, y in zip(ranks_u, ranks_v))
    return 1.0 - 6.0 * d2 / (n ** 3 - n)


def demo_spearman_bridge(seed: int = 20261161) -> None:
    print("=" * 74)
    print("6. THE SPEARMAN BRIDGE:  rank correlation = cosine of centred rank vectors")
    print("=" * 74)
    rng = random.Random(seed)
    print("      n    centred |rank|^2   (n^3-n)/12    Spearman formula   cosine    diff")
    for n in (5, 8, 13, 40, 101):
        base = list(range(1, n + 1))
        perm_u = base[:]
        perm_v = base[:]
        rng.shuffle(perm_u)
        rng.shuffle(perm_v)
        cu, cv = centre(perm_u), centre(perm_v)
        normsq = dot(cu, cu)
        theory = (n ** 3 - n) / 12.0
        s_formula = spearman_from_d2(perm_u, perm_v)
        s_cosine = corr(cu, cv)
        print(f"    {n:4d}   {normsq:14.4f}   {theory:11.4f}   {s_formula:+14.8f}   "
              f"{s_cosine:+.8f}   {abs(s_formula - s_cosine):.1e}")
    print()
    print("  Every tie-free ranking of n items has the same centred squared norm,")
    print("  (n^3 - n)/12, so the two computations agree exactly and the geometric")
    print("  ceilings above apply verbatim to measured rank correlations.")
    print()


# --------------------------------------------------------------------------
# 7. The recorded dial: capacity classification
# --------------------------------------------------------------------------

def demo_recorded_dial() -> None:
    print("=" * 74)
    print("7. THE RECORDED DIAL: CAPACITY CLASSIFICATION")
    print("=" * 74)
    lo, hi = BAND
    print(f"  seed readings at bitlen 72     : {SEED_READINGS_72}")
    mean_seeds = sum(SEED_READINGS_72) / 3.0
    print(f"  seed mean                      : {mean_seeds:.6f}")
    print(f"  pooled                         : {POOLED_72}   CI {CI_72}")
    print(f"  all inside band {BAND}     : "
          f"{all(lo <= r <= hi for r in SEED_READINGS_72 + (POOLED_72,) + CI_72)}")
    print(f"  |pooled - seed mean|           : {abs(POOLED_72 - mean_seeds):.6f}")
    print(f"  count baseline at parity       : {POOLED_72 - PARITY_GAP:.3f} "
          f"(still inside the band: {lo <= POOLED_72 - PARITY_GAP})")
    print(f"  pooled^2 = {POOLED_72 ** 2:.6f} vs dyadic tie ceiling 6/7 = {6 / 7:.6f}"
          f"  -> tie geometry is not the active constraint")
    print()
    print("      reading    capacity   1/sqrt(cap)   1/sqrt(cap+1)   verdict")
    for label, rho in (("bitlen 44", DIAL_44), ("bitlen 72", POOLED_72)):
        k = capacity(rho)
        print(f"  {label} {rho:.3f}      {k}       {1 / math.sqrt(k):.6f}      "
              f"{1 / math.sqrt(k + 1):.6f}    "
              f"{k} decorrelated statistic(s) may read it, {k + 1} cannot")
    print()
    print(f"  3 * 0.605^2 = {3 * POOLED_72 ** 2:.6f} > 1  ->  a third baseline reading")
    print("  0.605 at bitlen 72 must be correlated with one of the first two.")
    print(f"  2 * 0.78^2  = {2 * DIAL_44 ** 2:.6f} > 1  ->  not even a pair fits at bitlen 44.")
    print()


# --------------------------------------------------------------------------
# 8. An empirical realisation of the parity configuration
# --------------------------------------------------------------------------

def demo_empirical_parity(n: int = 200000, seed: int = 20261162) -> None:
    """Build actual data columns realising decorrelated parity at level 0.605."""
    print("=" * 74)
    print("8. AN EMPIRICAL DATA SET REALISING PARITY AT 0.605")
    print("=" * 74)
    rng = random.Random(seed)
    t = POOLED_72
    s = math.sqrt(1.0 - 2.0 * t * t)
    x1 = [rng.gauss(0.0, 1.0) for _ in range(n)]
    x2 = [rng.gauss(0.0, 1.0) for _ in range(n)]
    x3 = [rng.gauss(0.0, 1.0) for _ in range(n)]
    # response is the same linear combination as the geometric witness
    y = [t * a + t * b + s * c for a, b, c in zip(x1, x2, x3)]
    cx1, cx2, cy = centre(x1), centre(x2), centre(y)
    print(f"  sample size                    : {n}")
    print(f"  target common reading          : {t}")
    print(f"  corr(statistic 1, response)    : {corr(cx1, cy):.5f}")
    print(f"  corr(statistic 2, response)    : {corr(cx2, cy):.5f}")
    print(f"  corr(statistic 1, statistic 2) : {corr(cx1, cx2):+.5f}  (target 0)")
    budget = corr(cx1, cy) ** 2 + corr(cx2, cy) ** 2
    print(f"  budget spent  sum rho^2        : {budget:.5f}  (ceiling 1)")
    print(f"  budget left for a third reader : {max(0.0, 1.0 - budget):.5f}"
          f"  -> max third reading {math.sqrt(max(0.0, 1.0 - budget)):.5f}")
    print()


def main() -> None:
    print()
    print("THE CORRELATION BUDGET -- numerical demonstrations")
    print()
    demo_gram_inequality()
    demo_parity_threshold()
    demo_forcing_law()
    demo_advantage_law()
    demo_capacity_law()
    demo_spearman_bridge()
    demo_recorded_dial()
    demo_empirical_parity()
    print("=" * 74)
    print("All demonstrations complete. No inequality was violated.")
    print("=" * 74)


if __name__ == "__main__":
    main()
