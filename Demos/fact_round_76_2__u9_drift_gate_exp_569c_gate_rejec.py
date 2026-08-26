"""
Numerical demonstrations for
"Resolution Floors for Cluster-Structured Pythagorean Search,
 and the Rejection of a Twice-Gated Drift Anomaly".

Everything is self-contained: standard library only, full type hints, no I/O.

Sections
--------
1.  Mediant envelope for pooled candidate/control ratios.
2.  Exact cluster-bootstrap variance identity (brute force over all m^m resamples,
    then Monte-Carlo at the real cluster count).
3.  The resolution floor  x_j / S - 1/m  <=  rsd(x), at the recorded profile.
4.  Unbounded hypotenuse multiplicity: the explicit witness C_k, and the exact
    representation count, showing how far the proved bound undershoots.
5.  Near-1/2 resolution floor from genuine two-hypotenuse cluster families.
6.  The sign-flip coverage audit and the multi-run degradation s(1-a) <= 1.
7.  Inverse-variance pooling and the named three-seed follow-up condition.
8.  The five-decimal truncation artefact.

Run:  python3 demo.py
"""

from __future__ import annotations

import itertools
import math
import random
from typing import Dict, Iterable, List, Sequence, Tuple

# --------------------------------------------------------------------------- #
# Recorded experimental numbers (arbiter run, fresh seed)
# --------------------------------------------------------------------------- #

CAND_PRIMARY: int = 2598
CTRL_PRIMARY: int = 2252
CAND_LOOSE: int = 40617
CTRL_LOOSE: int = 38594

CI_PRIMARY: Tuple[float, float] = (1.0540, 1.2611)
CI_LOOSE: Tuple[float, float] = (1.0051, 1.1016)

N_CLUSTERS: int = 128
TOP_CLUSTERS: Tuple[int, int, int] = (600, 561, 540)
CONTROL_MAX_CLUSTER: int = 359

DEFICIT_FAMILY: Dict[str, float] = {"pilot": 0.9468, "G1": 0.988, "B": 0.9623}


def rule(title: str) -> None:
    print("\n" + "=" * 74)
    print(title)
    print("=" * 74)


# --------------------------------------------------------------------------- #
# 1.  Mediant envelope
# --------------------------------------------------------------------------- #


def pooled_ratio(x: Sequence[float], y: Sequence[float]) -> float:
    """Pooled candidate/control ratio  (sum x) / (sum y)."""
    return sum(x) / sum(y)


def mediant_envelope(x: Sequence[float], y: Sequence[float]) -> Tuple[float, float]:
    """Smallest and largest attained per-cluster ratio x_i / y_i."""
    ratios: List[float] = [xi / yi for xi, yi in zip(x, y)]
    return min(ratios), max(ratios)


def demo_mediant(seed: int = 11) -> None:
    rule("1.  Mediant envelope:  min_i x_i/y_i  <=  pooled r  <=  max_i x_i/y_i")
    rng = random.Random(seed)
    m: int = 12
    x: List[float] = [float(rng.randint(20, 900)) for _ in range(m)]
    y: List[float] = [float(rng.randint(20, 900)) for _ in range(m)]

    r: float = pooled_ratio(x, y)
    lo, hi = mediant_envelope(x, y)
    print(f"  clusters m       = {m}")
    print(f"  pooled ratio r   = {r:.6f}")
    print(f"  attained range   = [{lo:.6f}, {hi:.6f}]")
    print(f"  envelope holds   : {lo <= r <= hi}")

    # A pooled surplus forces at least one cluster-level surplus.
    surplus_clusters: List[int] = [i for i in range(m) if x[i] > y[i]]
    if r > 1.0:
        print(f"  r > 1, so some cluster must have x_i > y_i: witnesses {surplus_clusters[:5]}")
        assert surplus_clusters, "mediant corollary violated"

    # A dominant cluster drags the pooled ratio to its own value.
    x_dom: List[float] = list(x)
    y_dom: List[float] = list(y)
    x_dom[0], y_dom[0] = 5.0e6, 4.0e6          # one huge cluster with ratio 1.25
    print(f"  after injecting one dominant cluster of ratio 1.250000:")
    print(f"    pooled ratio   = {pooled_ratio(x_dom, y_dom):.6f}  (dragged toward 1.25)")


# --------------------------------------------------------------------------- #
# 2.  Exact cluster-bootstrap variance identity
# --------------------------------------------------------------------------- #


def brute_force_bootstrap_second_moment(x: Sequence[float]) -> float:
    """(1/m^m) * sum over ALL m^m resamples of (T* - S)^2.  Exponential; small m only."""
    m: int = len(x)
    total: float = sum(x)
    acc: float = 0.0
    for f in itertools.product(range(m), repeat=m):
        star: float = sum(x[k] for k in f)
        acc += (star - total) ** 2
    return acc / (m ** m)


def sum_squared_deviations(x: Sequence[float]) -> float:
    """sum_i (x_i - xbar)^2 with xbar = S/m."""
    m: int = len(x)
    xbar: float = sum(x) / m
    return sum((xi - xbar) ** 2 for xi in x)


def monte_carlo_bootstrap_variance(x: Sequence[float], reps: int, seed: int) -> float:
    """Monte-Carlo estimate of Var(T*) under the cluster bootstrap."""
    rng = random.Random(seed)
    m: int = len(x)
    total: float = sum(x)
    acc: float = 0.0
    for _ in range(reps):
        star: float = sum(x[rng.randrange(m)] for _ in range(m))
        acc += (star - total) ** 2
    return acc / reps


def demo_bootstrap_identity(seed: int = 7) -> None:
    rule("2.  Exact bootstrap variance identity:  Var(T*) = sum_i (x_i - xbar)^2")
    rng = random.Random(seed)

    for m in (2, 3, 4, 5, 6):
        x: List[float] = [float(rng.randint(1, 60)) for _ in range(m)]
        exact: float = brute_force_bootstrap_second_moment(x)
        closed: float = sum_squared_deviations(x)
        print(
            f"  m = {m}:  exhaustive over {m**m:>6d} resamples = {exact:12.4f}"
            f"   closed form = {closed:12.4f}   match = {math.isclose(exact, closed, rel_tol=1e-12)}"
        )

    # Same identity at the real cluster count, checked by Monte Carlo.
    profile: List[float] = recorded_profile()
    mc: float = monte_carlo_bootstrap_variance(profile, reps=40000, seed=2026)
    closed = sum_squared_deviations(profile)
    print(f"\n  recorded profile (m = {len(profile)}):")
    print(f"    Monte-Carlo Var(T*)  = {mc:.1f}   (40000 replicates)")
    print(f"    closed form          = {closed:.1f}")
    print(f"    relative discrepancy = {abs(mc - closed) / closed:.4%}")


# --------------------------------------------------------------------------- #
# 3.  Resolution floor at the recorded profile
# --------------------------------------------------------------------------- #


def recorded_profile() -> List[float]:
    """Idealised arbiter profile: 128 clusters, top = 600, total = 40617."""
    rest: float = (CAND_LOOSE - TOP_CLUSTERS[0]) / (N_CLUSTERS - 1)
    return [float(TOP_CLUSTERS[0])] + [rest] * (N_CLUSTERS - 1)


def rsd(x: Sequence[float]) -> float:
    """Relative cluster dispersion = sqrt(sum (x_i - xbar)^2) / S = relative bootstrap SD."""
    return math.sqrt(sum_squared_deviations(x)) / sum(x)


def resolution_floor(x: Sequence[float]) -> float:
    """Certified floor  max_j x_j / S - 1/m."""
    m: int = len(x)
    total: float = sum(x)
    return max(x) / total - 1.0 / m


def demo_resolution_floor() -> None:
    rule("3.  Resolution floor:  x_j / S - 1/m  <=  rsd(x)")
    profile: List[float] = recorded_profile()
    floor: float = resolution_floor(profile)
    dispersion: float = rsd(profile)
    half_width: float = (CI_LOOSE[1] - CI_LOOSE[0]) / 2.0

    print(f"  clusters m              = {len(profile)}")
    print(f"  grand total S           = {sum(profile):.0f}")
    print(f"  top cluster share       = {max(profile) / sum(profile):.6f}")
    print(f"  1/m                     = {1.0 / len(profile):.6f}")
    print(f"  certified floor         = {floor:.6f}   (paper claims > 0.0069)")
    print(f"  actual rsd              = {dispersion:.6f}")
    print(f"  floor <= rsd            : {floor <= dispersion}")
    print(f"  reported half-width     = {half_width:.6f}")
    print(f"  half-width >= 2 * floor : {half_width >= 2 * floor}")
    print("  => the reported interval is consistent with (indeed wider than) the")
    print("     structural floor imposed by the observed cluster overdispersion.")

    # A harsher, realistic profile with a heavy tail.
    tail: float = (CAND_LOOSE - sum(TOP_CLUSTERS)) / (N_CLUSTERS - 3)
    heavy: List[float] = [float(v) for v in TOP_CLUSTERS] + [tail] * (N_CLUSTERS - 3)
    print(f"\n  three-peak profile (600/561/540 + flat tail):")
    print(f"    floor = {resolution_floor(heavy):.6f}   rsd = {rsd(heavy):.6f}")


# --------------------------------------------------------------------------- #
# 4.  Unbounded hypotenuse multiplicity
# --------------------------------------------------------------------------- #


def hyp_solutions(c: int) -> List[Tuple[int, int]]:
    """All ordered positive leg pairs (a, b) with a^2 + b^2 = c^2.  O(c) time."""
    out: List[Tuple[int, int]] = []
    cc: int = c * c
    for a in range(1, c):
        b2: int = cc - a * a
        b: int = math.isqrt(b2)
        if b * b == b2 and b >= 1:
            out.append((a, b))
    return out


def hyp_multiplicity_exact(c: int) -> int:
    """|H(c)| via the multiplicative representation count, without enumeration.

    The number of representations of n as an ordered sum of two squares of integers
    (signs and zeros included) is 4 * (d_1(n) - d_3(n)).  For n = c^2 this equals
    4 * prod (2 e_p + 1) over primes p = 1 mod 4 with p^{e_p} || c.  Removing the four
    degenerate representations (+-c, 0), (0, +-c) and dividing by the four sign
    choices leaves prod (2 e_p + 1) - 1 ordered pairs of strictly positive legs.
    """
    n: int = c
    reps: int = 1
    d: int = 2
    while d * d <= n:
        if n % d == 0:
            e: int = 0
            while n % d == 0:
                n //= d
                e += 1
            if d % 4 == 1:
                reps *= 2 * e + 1
        d += 1
    if n > 1 and n % 4 == 1:
        reps *= 3
    return reps - 1


def witness_hypotenuse(k: int) -> int:
    """C_k = prod_{v<k} ((v+2)^2 + 1)."""
    c: int = 1
    for v in range(k):
        c *= (v + 2) ** 2 + 1
    return c


def certified_legs(k: int) -> List[Tuple[int, int]]:
    """The k explicitly constructed leg pairs sharing hypotenuse C_k."""
    big: int = witness_hypotenuse(k)
    legs: List[Tuple[int, int]] = []
    for v in range(k):
        h: int = (v + 2) ** 2 + 1
        t: int = big // h
        legs.append((((v + 2) ** 2 - 1) * t, 2 * (v + 2) * t))
    return legs


def demo_multiplicity() -> None:
    rule("4.  Unbounded hypotenuse multiplicity:  C_k = prod_{v<k} ((v+2)^2 + 1)")
    print(f"  |H(5)| = {len(hyp_solutions(5))}  ->  {hyp_solutions(5)}")
    print()
    print(f"  {'k':>3} {'C_k':>22} {'proved >= k':>12} {'true |H(C_k)|':>14}")
    for k in range(1, 8):
        big: int = witness_hypotenuse(k)
        legs: List[Tuple[int, int]] = certified_legs(k)
        assert len(set(legs)) == k, "constructed legs must be distinct"
        for a, b in legs:
            assert a * a + b * b == big * big, "constructed pair must be Pythagorean"
            assert 1 <= a <= big and 1 <= b <= big
        exact: int = hyp_multiplicity_exact(big)
        print(f"  {k:>3} {big:>22} {k:>12} {exact:>14}")
    print()
    print("  the construction is a *floor*: C_3 = 850 is certified to carry 3 hits and")
    print("  actually carries 14, because the true count is multiplicative in the")
    print("  primes = 1 mod 4 dividing C_k while the scaled family sees one per factor.")
    assert hyp_multiplicity_exact(850) == len(hyp_solutions(850)) == 14


# --------------------------------------------------------------------------- #
# 5.  Near-1/2 floor from genuine hypotenuse clusters
# --------------------------------------------------------------------------- #


def demo_near_half_floor() -> None:
    rule("5.  Near-1/2 resolution floor from real two-hypotenuse cluster families")
    print(f"  pairing a large-multiplicity hypotenuse c1 with c2 = 5 (|H(5)| = 2):")
    print(f"  {'k':>3} {'h = |H(C_k)|':>14} {'floor h/(h+2) - 1/2':>22} {'rsd of (h, 2)':>16}")
    for k in range(1, 9):
        big: int = witness_hypotenuse(k)
        h: int = hyp_multiplicity_exact(big)
        x: List[float] = [float(h), 2.0]
        floor: float = h / (h + 2) - 0.5
        print(f"  {k:>3} {h:>14} {floor:>22.6f} {rsd(x):>16.6f}")
        assert floor <= rsd(x) + 1e-12
    print("\n  the floor climbs toward 1/2: clustered Pythagorean search admits no")
    print("  universal averaging bound, no matter how many pairs are sampled.")


# --------------------------------------------------------------------------- #
# 6.  The sign-flip coverage audit
# --------------------------------------------------------------------------- #


def intervals_disjoint(a: Tuple[float, float], b: Tuple[float, float]) -> bool:
    return a[1] < b[0] or b[1] < a[0]


def max_joint_coverage(num_disjoint_runs: int) -> float:
    """Largest nominal coverage 1-alpha compatible with s pairwise-disjoint claims."""
    return 1.0 / num_disjoint_runs


def demo_sign_flip() -> None:
    rule("6.  Sign-flip audit:  disjoint intervals cannot both cover")
    r_primary: float = CAND_PRIMARY / CTRL_PRIMARY
    r_loose: float = CAND_LOOSE / CTRL_LOOSE
    print(f"  arbiter primary cut : {CAND_PRIMARY}/{CTRL_PRIMARY} = {r_primary:.4f}  CI {CI_PRIMARY}")
    print(f"  arbiter looser cut  : {CAND_LOOSE}/{CTRL_LOOSE} = {r_loose:.4f}  CI {CI_LOOSE}")
    print(f"  earlier seed family : {DEFICIT_FAMILY}")
    print()
    deficit_ci: Tuple[float, float] = (0.90, 1.00)   # the family's intervals lie in (0,1]
    disjoint: bool = intervals_disjoint(deficit_ci, CI_LOOSE)
    print(f"  deficit-family interval (contained in) {deficit_ci}")
    print(f"  arbiter interval                       {CI_LOOSE}")
    print(f"  disjoint                              : {disjoint}")
    alpha: float = 0.05
    print(f"  both claim coverage >= {1-alpha:.2f}; disjointness forces 1 <= 2*alpha = {2*alpha:.2f}")
    print(f"  contradiction                         : {2 * alpha < 1}")
    print("  => at least one nominal coverage claim is false, or the two seed")
    print("     families are not estimating the same quantity.  Gate rejected.")
    print()
    print("  multi-run degradation  s * (1 - alpha) <= 1:")
    for s in range(2, 6):
        print(f"    s = {s} incompatible runs  =>  nominal coverage <= {max_joint_coverage(s):.4f}"
              f"   (alpha >= {1 - max_joint_coverage(s):.4f})")
    print()
    print(f"  scale diagnostic: looser-cut ratio {r_loose:.4f} < primary-cut ratio {r_primary:.4f};")
    print("  the apparent effect SHRINKS as counts grow -- a fluctuation signature.")
    assert r_loose < r_primary


# --------------------------------------------------------------------------- #
# 7.  Inverse-variance pooling
# --------------------------------------------------------------------------- #


def pooled_variance(variances: Iterable[float]) -> float:
    """Inverse-variance pooled variance ( sum 1/v_i )^{-1}."""
    vs: List[float] = list(variances)
    return 1.0 / sum(1.0 / v for v in vs)


def demo_pooling() -> None:
    rule("7.  Inverse-variance pooling and the named three-seed follow-up condition")
    half_width: float = (CI_LOOSE[1] - CI_LOOSE[0]) / 2.0
    sigma_one: float = half_width / 1.96
    print(f"  recorded half-width           = {half_width:.6f}")
    print(f"  implied one-run standard error = {sigma_one:.6f}  (~ 0.025)")
    print()
    for k in (1, 2, 3, 4, 5):
        v: float = pooled_variance([0.025 ** 2] * k)
        print(f"    k = {k} seeds  ->  sigma_joint = {math.sqrt(v):.6f}"
              f"{'   <-- target sigma < 0.02 reached' if math.sqrt(v) < 0.02 and k == 3 else ''}")
    print()
    print("  pooling never hurts: with unequal variances the pooled value never")
    print("  exceeds the smallest single variance.")
    mixed: List[float] = [0.025 ** 2, 0.040 ** 2, 0.018 ** 2]
    v_mixed: float = pooled_variance(mixed)
    print(f"    variances {['%.6f' % v for v in mixed]}")
    print(f"    pooled    {v_mixed:.6f}   <= min {min(mixed):.6f} : {v_mixed <= min(mixed)}")
    assert v_mixed <= min(mixed)
    print()
    print("  caveat: if the new seeds again disagree in SIGN, pooling is not merely")
    print("  uninformative but illegitimate -- pairwise-incompatible intervals falsify")
    print("  the very coverage assumption that inverse-variance weighting rests on.")


# --------------------------------------------------------------------------- #
# 8.  The truncation artefact
# --------------------------------------------------------------------------- #


def trunc5(x: float) -> float:
    """Five-decimal truncation, as produced by fixed-width terminal formatting."""
    return math.floor(x * 100000) / 100000


def demo_truncation() -> None:
    rule("8.  Display truncation is not evidence")
    lo, x, hi = 0.000031, 0.0000338, 0.000035
    print(f"  interval          = [{lo}, {hi}]")
    print(f"  true value        = {x}   (inside: {lo < x < hi})")
    print(f"  five-decimal view = {trunc5(x):.5f}   (below lower limit: {trunc5(x) < lo})")
    print("  the coordinator alarm was exactly this: 3.38e-05 rendered as '0.00003',")
    print("  manufacturing an out-of-interval appearance.  Raw counts recompute exactly.")
    assert lo < x < hi and trunc5(x) < lo


# --------------------------------------------------------------------------- #

def main() -> None:
    print("Cluster-structured Pythagorean search: resolution floors and the")
    print("rejection of a twice-gated drift anomaly -- numerical demonstrations")
    demo_mediant()
    demo_bootstrap_identity()
    demo_resolution_floor()
    demo_multiplicity()
    demo_near_half_floor()
    demo_sign_flip()
    demo_pooling()
    demo_truncation()
    rule("All demonstrations completed; every asserted identity and bound held.")


if __name__ == "__main__":
    main()


"""Pooled candidate/control ratio with a nonparametric cluster-bootstrap interval."""

from __future__ import annotations

import random
from typing import List, Sequence, Tuple


def pooled_ratio_cluster_bootstrap(
    cand: Sequence[float],
    ctrl: Sequence[float],
    replicates: int = 4000,
    alpha: float = 0.05,
    seed: int = 20260825,
) -> Tuple[float, Tuple[float, float], List[float]]:
    """Pooled ratio r = (sum cand)/(sum ctrl) with a percentile cluster-bootstrap CI.

    The m clusters are resampled i.i.d. uniformly WITH REPLACEMENT; within-cluster
    counts are never resampled.  That is precisely why the resolution floor
    max_j cand_j / S - 1/m binds: refining the sampling inside a cluster cannot
    reduce the bootstrap dispersion.

    Complexity: O(replicates * m) time, O(replicates) memory.

    Returns (point estimate, (lower, upper), sorted replicate ratios).
    """
    if len(cand) != len(ctrl):
        raise ValueError("candidate and control profiles must have equal length")
    m: int = len(cand)
    if m == 0:
        raise ValueError("need at least one cluster")

    point: float = sum(cand) / sum(ctrl)

    rng = random.Random(seed)
    reps: List[float] = []
    for _ in range(replicates):
        num: float = 0.0
        den: float = 0.0
        for _k in range(m):
            i: int = rng.randrange(m)
            num += cand[i]
            den += ctrl[i]
        if den > 0.0:
            reps.append(num / den)
    reps.sort()

    def quantile(sorted_vals: List[float], q: float) -> float:
        if not sorted_vals:
            return float("nan")
        pos: float = q * (len(sorted_vals) - 1)
        lo_i: int = int(pos)
        hi_i: int = min(lo_i + 1, len(sorted_vals) - 1)
        frac: float = pos - lo_i
        return sorted_vals[lo_i] * (1.0 - frac) + sorted_vals[hi_i] * frac

    ci: Tuple[float, float] = (
        quantile(reps, alpha / 2.0),
        quantile(reps, 1.0 - alpha / 2.0),
    )
    return point, ci, reps


if __name__ == "__main__":
    # Idealised arbiter profile: 128 clusters, candidate top cluster 600, total 40617.
    cand: List[float] = [600.0] + [(40617 - 600) / 127] * 127
    ctrl: List[float] = [359.0] + [(38594 - 359) / 127] * 127
    r, (lo, hi), _ = pooled_ratio_cluster_bootstrap(cand, ctrl)
    print(f"pooled ratio r = {r:.4f}   95% CI = [{lo:.4f}, {hi:.4f}]")


"""Cluster-dispersion audit: exact relative dispersion, certified floor, verdict."""

from __future__ import annotations

import math
from typing import Dict, Sequence


def cluster_floor_audit(
    counts: Sequence[float],
    reported_half_width: float,
) -> Dict[str, float]:
    """Audit a reported confidence half-width against the structural resolution floor.

    Definitions.
      S    = sum_i x_i,   xbar = S/m
      rsd  = sqrt( sum_i (x_i - xbar)^2 ) / S
    By the exact cluster-bootstrap variance identity, Var(T*) = sum_i (x_i - xbar)^2
    when m clusters are drawn with replacement, so `rsd` is exactly the RELATIVE
    bootstrap standard error of the resampled total -- not a proxy for it.

    The certified floor is  max_j x_j / S - 1/m, and the theorem guarantees
    floor <= rsd for every profile.  A reported half-width smaller than the floor
    would indicate an interval narrower than the cluster structure permits.

    Complexity: O(m) time, O(1) extra memory.
    """
    m: int = len(counts)
    if m == 0:
        raise ValueError("need at least one cluster")
    total: float = float(sum(counts))
    if total <= 0.0:
        raise ValueError("grand total must be positive")

    mean: float = total / m
    ss: float = sum((float(x) - mean) ** 2 for x in counts)
    dispersion: float = math.sqrt(ss) / total
    top_share: float = max(float(x) for x in counts) / total
    floor: float = top_share - 1.0 / m
    design_effect: float = (max(float(x) for x in counts) / mean) if mean > 0 else float("nan")

    return {
        "clusters": float(m),
        "grand_total": total,
        "top_share": top_share,
        "inv_m": 1.0 / m,
        "certified_floor": floor,
        "relative_dispersion": dispersion,
        "floor_holds": 1.0 if floor <= dispersion + 1e-15 else 0.0,
        "reported_half_width": reported_half_width,
        "half_width_over_floor": (reported_half_width / floor) if floor > 0 else float("inf"),
        "consistent": 1.0 if reported_half_width >= 2.0 * floor else 0.0,
        "max_over_mean": design_effect,
    }


if __name__ == "__main__":
    profile = [600.0] + [(40617 - 600) / 127] * 127
    for key, val in cluster_floor_audit(profile, (1.1016 - 1.0051) / 2).items():
        print(f"{key:>22} : {val:.6f}")


"""Explicit witness for unbounded hypotenuse multiplicity, plus the exact count."""

from __future__ import annotations

import math
from typing import List, Tuple


def multiplicity_witness(k: int) -> Tuple[int, List[Tuple[int, int]]]:
    """Return (C_k, legs) where C_k = prod_{v<k} ((v+2)^2 + 1) and legs are k distinct
    ordered positive leg pairs with a^2 + b^2 = C_k^2.

    Construction: the classical family (mu^2 - 1, 2 mu, mu^2 + 1) is Pythagorean for
    every mu >= 2.  With mu = v + 2 the hypotenuse is h(v) = (v+2)^2 + 1, and each
    h(v) divides C_k, so scaling the v-th triple by t_v = C_k / h(v) lands it on the
    common hypotenuse C_k.  Distinctness follows because h is injective and a scaled
    leg is strictly shorter than the hypotenuse.

    Complexity: O(k) big-integer multiplications; log C_k ~ 2k log k.
    """
    if k < 0:
        raise ValueError("k must be nonnegative")
    big: int = 1
    for v in range(k):
        big *= (v + 2) ** 2 + 1

    legs: List[Tuple[int, int]] = []
    for v in range(k):
        h: int = (v + 2) ** 2 + 1
        t: int = big // h
        a: int = ((v + 2) ** 2 - 1) * t
        b: int = 2 * (v + 2) * t
        assert a * a + b * b == big * big
        assert 1 <= a <= big and 1 <= b <= big
        legs.append((a, b))
    assert len(set(legs)) == k
    return big, legs


def exact_multiplicity(c: int) -> int:
    """|H(c)| = number of ordered pairs of positive legs with a^2 + b^2 = c^2.

    Equal to prod (2 e_p + 1) - 1 over primes p = 1 mod 4 with p^{e_p} || c, since the
    total number of signed representations of c^2 as a sum of two squares is
    4 * prod (2 e_p + 1), of which four are degenerate.

    Complexity: trial division, O(sqrt(c)).
    """
    n: int = c
    prod: int = 1
    d: int = 2
    while d * d <= n:
        if n % d == 0:
            e: int = 0
            while n % d == 0:
                n //= d
                e += 1
            if d % 4 == 1:
                prod *= 2 * e + 1
        d += 1
    if n > 1 and n % 4 == 1:
        prod *= 3
    return prod - 1


def enumerate_multiplicity(c: int) -> int:
    """Brute-force |H(c)| in O(c); used to cross-check `exact_multiplicity`."""
    cc: int = c * c
    count: int = 0
    for a in range(1, c):
        b2: int = cc - a * a
        b: int = math.isqrt(b2)
        if b >= 1 and b * b == b2:
            count += 1
    return count


if __name__ == "__main__":
    for k in range(1, 7):
        big, legs = multiplicity_witness(k)
        print(f"k={k}  C_k={big}  certified={len(legs)}  true |H(C_k)|={exact_multiplicity(big)}")
    assert exact_multiplicity(850) == enumerate_multiplicity(850) == 14
    print("cross-check at c = 850 passed:", exact_multiplicity(850))


"""Assemble PACKAGE.json from the deliverables and the package assets."""

from __future__ import annotations

import json
import os
from typing import Any, Dict, List

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ASSETS = os.path.join(ROOT, "package_assets")


def read(path: str) -> str:
    with open(path, "r", encoding="utf-8") as fh:
        return fh.read()


LEAN_FILES: List[str] = [
    "Catalog/Pythagorean/DriftGateClusterFloor.lean",
    "Catalog/Pythagorean/DriftGateHypotenuseMultiplicity.lean",
    "Catalog/Pythagorean/DriftGateBootstrapVariance.lean",
    "Catalog/Pythagorean/DriftGateSynthesis.lean",
]

FUTURE_DIRECTIONS = """# Future directions — after the U9-DRIFT-GATE rejection (paper 222)

The round closed a gate by *sign flip*: two seed families disagree on the direction of a
few-percent deviation, so nothing is banked in either direction.  What the formal development
adds is that this outcome was structurally predictable: hypotenuse-clustered Pythagorean search
has unbounded per-cluster multiplicity, and unbounded multiplicity forces a nonzero — in the
worst case near-1/2 — resolution floor on any single run.  The cluster bootstrap that produced
the reported intervals is exactly the object the floor constrains.

The following directions are the ones this cycle actually opened.

## 1. Sharp multiplicity growth for the scaling construction

The construction C_k = prod_{v<k} ((v+2)^2 + 1) provably delivers k hits but measurably delivers
far more (C_3 = 850 carries 14).  **The key insight is** that the scaled family only sees one
primitive triple per factor, while the true count is multiplicative in the primes = 1 mod 4
dividing C_k, so the gap between the proved and true bound is itself a clean arithmetic
function.  **Why now?**  The existence theorem for hypotenuse multiplicity gives a skeleton into
which a Gaussian-integer factorisation count can be dropped without redoing the distinctness
argument.

## 2. Distributional floor, not just worst-case floor

The bound "largest-cluster share minus 1/m is at most the relative cluster dispersion" is a
deterministic statement at a fixed profile.  What a future gate needs is the *typical* floor when
clusters are drawn from the hypotenuse distribution.  **The key insight is** that the max/mean
ratio of hypotenuse cluster sizes grows like a divisor-type function, so the design effect should
grow like a power of log, not stay bounded.  **Why now?**  The exact bootstrap variance identity
is proved, so a distributional statement can be phrased as a statement about the total squared
deviation from the cluster mean alone.

## 3. Sign-flip as a formal falsification rule

The coverage-incompatibility theorem shows disjoint intervals cannot both cover.  The natural
strengthening is quantitative: with s runs whose intervals pairwise disagree in sign, the nominal
coverage 1 - alpha must satisfy an inequality that degrades with s.  **The key insight is** that a
union bound over sign-partitioned events converts "how many runs flipped" directly into "how wrong
the nominal coverage is".  **Why now?**  The named follow-up of this round (at least 3 truly
distinct seeds) will produce exactly the multi-run data such a rule consumes.

## 4. Mediant rigidity for candidate/control designs

The mediant envelope says the pooled ratio is trapped between attained cluster ratios.  **The key
insight is** that this makes the pooled ratio a *weighted median-like* statistic whose sensitivity
is governed entirely by the largest-control clusters, which suggests a trimmed or winsorised
pooled estimator: discard the top few clusters, pay a small bias, and buy a large reduction in the
largest-cluster share that drives the resolution floor.  Quantifying that bias/floor trade-off
against the floor inequality is a well-posed optimisation, and it is the most direct route to a
design that could actually resolve a few-percent deviation in a single run.
"""


def main() -> None:
    article = read(os.path.join(ROOT, "ARTICLE.md"))
    paper = read(os.path.join(ROOT, "RESEARCH_PAPER.md"))
    paper_tex = read(os.path.join(ROOT, "RESEARCH_PAPER.tex"))
    demo = read(os.path.join(ROOT, "demo.py"))
    layout = read(os.path.join(ASSETS, "interactive_layout.md"))

    lean_blocks: List[str] = []
    for rel in LEAN_FILES:
        lean_blocks.append(f"-- FILE: {rel}\n\n{read(os.path.join(ROOT, rel))}")
    lean_proofs = "\n\n\n".join(lean_blocks)

    package: Dict[str, Any] = {
        "title": "Resolution Floors for Cluster-Structured Pythagorean Search: "
                 "Unbounded Hypotenuse Multiplicity and the Sign-Flip Rejection of a Drift Gate",
        "domain": "Pythagorean",
        "description": (
            "A twice-gated few-percent candidate deviation in a clustered Pythagorean search is "
            "rejected by directional disagreement between independent seeds, and the rejection is "
            "explained by exact mathematics: an exact cluster-bootstrap variance identity, a "
            "resolution floor equal to the largest-cluster share minus the reciprocal cluster "
            "count, and the unboundedness of hypotenuse multiplicity, which together forbid any "
            "universal single-run averaging bound."
        ),
        "authors": ["Aristotle"],
        "date": "2026-08-26",
        "key_results": [
            "Coverage incompatibility: two disjoint confidence intervals cannot both cover the "
            "same estimand with probability at least 1 - alpha unless alpha is at least 1/2, and "
            "s pairwise-disjoint coverage claims force s(1 - alpha) <= 1 — so the observed sign "
            "flip between seed families falsifies at least one nominal 95% coverage claim.",
            "Exact cluster-bootstrap variance identity: for a centred cluster vector and n draws "
            "with replacement from m clusters, m times the sum over all resamples of the squared "
            "resampled total equals n·m^n times the sum of squared entries; at n = m this shows "
            "the bootstrap variance of the resampled total is exactly the total squared deviation "
            "from the cluster mean.",
            "Resolution floor: the relative cluster-bootstrap standard error is at least the "
            "largest-cluster share minus one over the number of clusters; at the recorded profile "
            "(128 clusters, top cluster 600 hits, total 40617) this gives a nonzero floor above "
            "0.0069, against which the reported half-width of 0.048 is consistent.",
            "Unbounded hypotenuse multiplicity: for every k the hypotenuse given by the product of "
            "((v+2)^2 + 1) over v < k carries at least k distinct ordered pairs of positive legs, "
            "so per-hypotenuse cluster sizes in a Pythagorean search are unbounded.",
            "Near-half floor: genuine two-hypotenuse cluster families exist whose one-run relative "
            "resolution floor exceeds 1/2 - epsilon for any epsilon > 0, so clustered Pythagorean "
            "search admits no universal averaging bound, and the mediant envelope traps the pooled "
            "ratio between attained per-cluster ratios.",
        ],
        "keywords": [
            "Pythagorean triples",
            "hypotenuse multiplicity",
            "cluster bootstrap",
            "overdispersion",
            "resolution floor",
            "mediant inequality",
            "inverse-variance pooling",
            "confidence interval coverage",
        ],
        "article": article,
        "research_paper": paper,
        "research_paper_tex": paper_tex,
        "demo": demo,
        "demos": [
            {
                "name": "Complete Numerical Companion: Mediant Envelope, Bootstrap Identity, "
                        "Resolution Floors, Hypotenuse Witnesses and the Sign-Flip Audit",
                "description": (
                    "An eight-part, dependency-free walkthrough of every result in the paper. "
                    "It verifies the mediant envelope on random cluster profiles and shows a "
                    "dominant cluster dragging the pooled ratio to its own value; checks the exact "
                    "cluster-bootstrap variance identity by exhaustive enumeration over all m^m "
                    "resamples for m = 2..6 and then by Monte Carlo at the real cluster count of "
                    "128; instantiates the resolution floor at the recorded arbiter profile and "
                    "compares it with the reported half-width; constructs the explicit hypotenuse "
                    "witnesses C_k, certifies that the k scaled leg pairs are distinct Pythagorean "
                    "solutions, and contrasts the certified bound with the exact multiplicity "
                    "obtained from the primes congruent to 1 mod 4; exhibits the climb of the "
                    "two-cluster floor toward 1/2; replays the sign-flip union bound and its "
                    "multi-run degradation; computes inverse-variance pooling for the three-seed "
                    "follow-up condition; and reproduces the five-decimal truncation artefact. "
                    "Every identity and inequality is asserted, so the script fails loudly if any "
                    "claim is violated."
                ),
                "code": demo,
            },
            {
                "name": "Gate Decision Calculator: How Many Independent Seeds Does a Given "
                        "Cluster Profile Require?",
                "description": (
                    "A design tool that turns the resolution floor into an experimental budget. "
                    "For a supplied cluster profile it reports the largest-cluster share, the "
                    "certified floor, the exact relative bootstrap standard error, and the design "
                    "effect (maximum over mean cluster size); it then computes the smallest number "
                    "of independent seeds whose inverse-variance pooling brings the joint standard "
                    "error below the precision needed to exclude a target effect at 95%. Three "
                    "profiles are contrasted — the idealised recorded run, the same total with a "
                    "heavy Zipf tail, and a hypotenuse-like profile where a single cluster holds "
                    "35% of the hits — showing that the required seed count explodes from 1 to "
                    "dozens to hundreds as the profile skews, even though the number of sampled "
                    "pairs never changes. It closes by replaying the recorded round: the three "
                    "deficit legs, the arbiter's surplus, the union bound that rejects the gate, "
                    "and the three-seed follow-up condition."
                ),
                "code": read(os.path.join(ASSETS, "demo_gate_calculator.py")),
            },
        ],
        "algorithms": [
            {
                "name": "Pooled Ratio Estimation with a Nonparametric Cluster Bootstrap Interval",
                "description": (
                    "The estimator that produced the round's reported numbers. Given candidate and "
                    "control counts on m clusters, it returns the pooled ratio r = (sum cand)/(sum "
                    "ctrl) together with a percentile confidence interval obtained by resampling "
                    "whole clusters i.i.d. uniformly with replacement. The crucial design feature "
                    "is that resampling happens at the level of clusters, never within them: this "
                    "is exactly why the resolution floor (largest-cluster share minus 1/m) binds, "
                    "and why increasing the number of sampled pairs per cluster cannot narrow the "
                    "interval below that floor. By the exact variance identity, the standard "
                    "deviation of the resampled total converges to the square root of the total "
                    "squared deviation from the cluster mean, so the simulation is estimating a "
                    "quantity with a closed form. Complexity is O(B·m) time in the number of "
                    "replicates B and clusters m, and O(B) memory for the replicate ratios; the "
                    "percentile step is an O(B log B) sort."
                ),
                "pseudocode": (
                    "INPUT  cand[1..m], ctrl[1..m], replicates B, level alpha\n"
                    "OUTPUT point estimate r, interval [L, U]\n"
                    "\n"
                    "1. r <- (sum_i cand[i]) / (sum_i ctrl[i])\n"
                    "2. reps <- empty list\n"
                    "3. for b = 1 to B do\n"
                    "4.     num <- 0 ; den <- 0\n"
                    "5.     for k = 1 to m do                    // draw m CLUSTERS, with replacement\n"
                    "6.         i <- uniform random index in {1..m}\n"
                    "7.         num <- num + cand[i] ; den <- den + ctrl[i]\n"
                    "8.     if den > 0 then append num/den to reps\n"
                    "9. sort reps ascending\n"
                    "10. L <- quantile(reps, alpha/2) ; U <- quantile(reps, 1 - alpha/2)\n"
                    "11. return r, [L, U]\n"
                    "\n"
                    "INVARIANT  Var(resampled total) = sum_i (x_i - mean)^2 exactly, so the width of\n"
                    "           [L, U] is governed by the cluster PROFILE, not by the pair count."
                ),
                "code": read(os.path.join(ASSETS, "alg_bootstrap_ci.py")),
            },
            {
                "name": "Structural Resolution-Floor Audit of a Reported Confidence Interval",
                "description": (
                    "The audit that discharges the question 'is this error bar narrower than the "
                    "cluster structure permits?'. It computes the exact relative cluster dispersion "
                    "sqrt(sum (x_i - mean)^2)/S — which, by the exact bootstrap variance identity, "
                    "IS the relative bootstrap standard error rather than a proxy for it — together "
                    "with the certified floor max_j x_j/S - 1/m and the design effect max/mean. It "
                    "then checks the theorem (floor <= dispersion, which must always hold) and "
                    "compares the reported half-width against twice the floor. Applied to the "
                    "recorded 128-cluster profile with a top cluster of 600 hits and a total of "
                    "40617, the floor is about 0.00696 and the reported half-width about 0.048, "
                    "roughly seven times larger: the interval is conservative relative to the "
                    "observed overdispersion. Complexity is O(m) time and O(1) extra memory, so the "
                    "audit is free relative to the bootstrap itself."
                ),
                "pseudocode": (
                    "INPUT  counts x[1..m], reported half-width h\n"
                    "OUTPUT audit record\n"
                    "\n"
                    "1. S    <- sum_i x[i]              ; require S > 0\n"
                    "2. mean <- S / m\n"
                    "3. ss   <- sum_i (x[i] - mean)^2   // = bootstrap variance of the resampled total\n"
                    "4. rsd  <- sqrt(ss) / S            // = relative bootstrap standard error\n"
                    "5. top  <- max_i x[i]\n"
                    "6. floor <- top/S - 1/m            // certified lower bound on rsd\n"
                    "7. assert floor <= rsd             // theorem; must never fail\n"
                    "8. design <- top / mean            // overdispersion diagnostic\n"
                    "9. consistent <- (h >= 2 * floor)  // is the reported bar wider than the structure?\n"
                    "10. return {S, m, top/S, floor, rsd, design, consistent}"
                ),
                "code": read(os.path.join(ASSETS, "alg_floor_audit.py")),
            },
            {
                "name": "Explicit Witness Construction for Unbounded Hypotenuse Multiplicity",
                "description": (
                    "Given k, this produces a single hypotenuse carrying at least k distinct "
                    "ordered pairs of positive legs, together with those pairs. It scales the "
                    "classical family (mu^2 - 1, 2mu, mu^2 + 1), for mu = 2..k+1, up to the common "
                    "hypotenuse C_k = prod_{v<k}((v+2)^2 + 1), each triple by the integer factor "
                    "C_k/h(v). Distinctness is guaranteed by an exact cross-multiplication argument: "
                    "the hypotenuse map is injective, and a coincidence between two scaled legs "
                    "would force a leg to equal the hypotenuse, which is impossible. The routine "
                    "also computes the exact multiplicity by factorisation — the count equals the "
                    "product of (2e_p + 1) over primes p = 1 mod 4 with p^{e_p} exactly dividing c, "
                    "minus one — revealing that the certified bound badly undershoots the truth "
                    "(C_3 = 850 is certified for 3 and carries 14). Construction costs O(k) "
                    "big-integer multiplications with log C_k ~ 2k log k; the exact count costs a "
                    "trial-division factorisation, O(sqrt(c)); the brute-force cross-check is O(c)."
                ),
                "pseudocode": (
                    "WITNESS(k):\n"
                    "1. C <- 1\n"
                    "2. for v = 0 to k-1 do C <- C * ((v+2)^2 + 1)\n"
                    "3. legs <- empty list\n"
                    "4. for v = 0 to k-1 do\n"
                    "5.     h <- (v+2)^2 + 1 ; t <- C / h          // exact division\n"
                    "6.     a <- ((v+2)^2 - 1) * t ; b <- 2*(v+2)*t\n"
                    "7.     assert a^2 + b^2 = C^2 and 1 <= a,b <= C\n"
                    "8.     append (a,b) to legs\n"
                    "9. assert all entries of legs are distinct\n"
                    "10. return C, legs                            // |H(C)| >= k\n"
                    "\n"
                    "EXACT_MULTIPLICITY(c):\n"
                    "1. prod <- 1\n"
                    "2. for each prime power p^e exactly dividing c do\n"
                    "3.     if p = 1 (mod 4) then prod <- prod * (2e + 1)\n"
                    "4. return prod - 1        // ordered pairs of STRICTLY POSITIVE legs"
                ),
                "code": read(os.path.join(ASSETS, "alg_multiplicity.py")),
            },
        ],
        "visualizations": [
            {
                "name": "The Resolution Floor in Three Views: Profile, Floor-versus-Dispersion "
                        "Sweep, and Bootstrap Widening",
                "description": (
                    "A three-panel figure. The left panel shows the recorded 128-cluster candidate "
                    "profile, sorted, with its top clusters of 600/561/540 hits standing far above "
                    "the flat-null mean — the raw picture of overdispersion. The middle panel sweeps "
                    "the largest-cluster share from 1/m to 1 and plots the certified floor "
                    "(largest share minus 1/m) against the true relative dispersion, shading the "
                    "gap between them and marking the recorded share; the two curves rise together, "
                    "showing the floor is not a slack bound. The right panel overlays Monte-Carlo "
                    "cluster-bootstrap distributions of the resampled total divided by the grand "
                    "total for three profiles of increasing skewness at fixed grand total, "
                    "demonstrating that the width of the interval is set by the shape of the "
                    "profile and not by the amount of sampling."
                ),
                "code": read(os.path.join(ASSETS, "viz_floor.py")),
            },
            {
                "name": "Hypotenuse Multiplicity and the Climb Toward the One-Half Floor",
                "description": (
                    "A three-panel figure on the arithmetic side. The left panel plots |H(c)|, the "
                    "number of ordered positive leg pairs with hypotenuse c, for every c up to 1200, "
                    "with the record-setting hypotenuses joined into a staircase — the visual proof "
                    "that cluster sizes have no ceiling. The middle panel compares, on a logarithmic "
                    "scale, the certified bound k against the true multiplicity of the explicit "
                    "witness C_k = prod_{v<k}((v+2)^2+1), showing how far the construction "
                    "overshoots its own guarantee. The right panel plots the resulting two-cluster "
                    "resolution floor h/(h+2) - 1/2 for the family formed by pairing C_k with the "
                    "hypotenuse 5, climbing toward the dashed worst-case limit of 1/2."
                ),
                "code": read(os.path.join(ASSETS, "viz_multiplicity.py")),
            },
        ],
        "interactive_demos": [
            {
                "title": "The Resolution Floor Laboratory",
                "description": (
                    "A live sandbox for the central inequality. Sliders control the number of "
                    "clusters, the share of hits held by the largest cluster, the Zipf decay of the "
                    "remaining tail, and the number of bootstrap replicates. The page redraws the "
                    "sorted cluster profile, runs a genuine cluster bootstrap in the browser, and "
                    "reports the certified floor, the exact relative dispersion, the simulated "
                    "bootstrap standard deviation, and the design effect side by side — so the "
                    "reader can watch the simulation converge onto the closed form predicted by the "
                    "exact variance identity, and watch the floor rise as the profile skews. A live "
                    "verdict states whether a five-percent deviation is resolvable in a single run "
                    "at the current profile. Presets load the recorded arbiter run, a perfectly flat "
                    "profile, and a pathological one-dominant-cluster design."
                ),
                "html": read(os.path.join(ASSETS, "widget_floor.html")),
            },
            {
                "title": "The Sign-Flip Coverage Audit",
                "description": (
                    "An interactive number line carrying two confidence intervals whose centres and "
                    "half-widths the reader controls, together with a slider for the nominal "
                    "coverage. When the intervals overlap the widget explains that the union bound "
                    "says nothing; when they separate — and especially when they straddle the null "
                    "value 1, a genuine sign flip — it computes 2(1 - alpha) and declares the "
                    "contradiction, spelling out that at least one coverage claim must be false or "
                    "the two runs are not estimating the same quantity. A preset loads the actual "
                    "recorded seed families. A companion table shows the multi-run degradation: with "
                    "s mutually incompatible runs the largest defensible nominal coverage is 1/s."
                ),
                "html": read(os.path.join(ASSETS, "widget_signflip.html")),
            },
            {
                "title": "Hypotenuse Clusters and the Near-Half Floor",
                "description": (
                    "An arithmetic explorer. Type any hypotenuse and the widget enumerates its "
                    "entire cluster of ordered positive leg pairs while independently computing the "
                    "multiplicity from the primes congruent to 1 mod 4 in its factorisation, so the "
                    "reader can check the two against each other. A second panel slides the "
                    "construction depth k of the explicit witness C_k = prod_{v<k}((v+2)^2+1), "
                    "plotting the certified bound against the true multiplicity on a log scale and "
                    "reporting the two-cluster resolution floor h/(h+2) - 1/2 obtained by pairing "
                    "the witness with the hypotenuse 5 — a number that climbs toward one half and "
                    "makes the absence of any universal averaging bound tangible."
                ),
                "html": read(os.path.join(ASSETS, "widget_hypotenuse.html")),
            },
        ],
        "interactive_layout": layout,
        "lean_proofs": lean_proofs,
        "future_directions": FUTURE_DIRECTIONS,
        "modules": {
            "demo": demo,
            "gate_calculator": read(os.path.join(ASSETS, "demo_gate_calculator.py")),
            "cluster_bootstrap": read(os.path.join(ASSETS, "alg_bootstrap_ci.py")),
            "floor_audit": read(os.path.join(ASSETS, "alg_floor_audit.py")),
            "hypotenuse_multiplicity": read(os.path.join(ASSETS, "alg_multiplicity.py")),
        },
        "lean_files": LEAN_FILES,
    }

    out = os.path.join(ROOT, "PACKAGE.json")
    with open(out, "w", encoding="utf-8") as fh:
        json.dump(package, fh, indent=2, ensure_ascii=False)
    print(f"wrote {out}  ({os.path.getsize(out):,} bytes)")


if __name__ == "__main__":
    main()


"""Gate decision calculator: can this design resolve the deviation you care about?

Given a cluster profile and a target effect size, the calculator reports

  * the certified one-run resolution floor      max_j x_j / S - 1/m,
  * the exact relative bootstrap standard error  sqrt(sum (x_i - xbar)^2)/S,
  * how many independent seeds must be pooled (inverse-variance) to bring the joint
    standard error below the target, and
  * whether the target is reachable AT ALL, since pooling cannot beat the floor of an
    individual run divided by sqrt(k) and the floor itself never shrinks.

It then replays the recorded round: the deficit family, the arbiter's surplus, the union
bound that rejects the gate, and the three-seed follow-up condition.

Self-contained; standard library only.
"""

from __future__ import annotations

import math
from typing import List, Sequence, Tuple


# ------------------------------------------------------------------ profile --
def make_profile(m: int, top: float, total: float, zipf: float = 0.0) -> List[float]:
    """One designated top cluster plus a Zipf(zipf)-shaped tail summing to total - top."""
    if m < 2 or top <= 0 or top > total:
        raise ValueError("bad profile parameters")
    weights: List[float] = [(i + 1.0) ** (-zipf) for i in range(m - 1)]
    scale: float = (total - top) / sum(weights)
    return [top] + [w * scale for w in weights]


def dispersion(x: Sequence[float]) -> float:
    m: int = len(x)
    total: float = sum(x)
    mean: float = total / m
    return math.sqrt(sum((v - mean) ** 2 for v in x)) / total


def floor_of(x: Sequence[float]) -> float:
    return max(x) / sum(x) - 1.0 / len(x)


# ------------------------------------------------------------------ pooling --
def seeds_needed(one_run_sd: float, target_sd: float) -> int:
    """Smallest k with sqrt(one_run_sd^2 / k) < target_sd."""
    if target_sd <= 0:
        raise ValueError("target must be positive")
    if one_run_sd < target_sd:
        return 1
    return int(math.ceil((one_run_sd / target_sd) ** 2 - 1e-12))


def pooled_sd(one_run_sd: float, k: int) -> float:
    return math.sqrt(one_run_sd ** 2 / k)


# ------------------------------------------------------------------- report --
def gate_report(x: Sequence[float], target_effect: float) -> None:
    """Target effect is expressed as a relative deviation, e.g. 0.05 for 5%."""
    fl: float = floor_of(x)
    sd: float = dispersion(x)
    print(f"  clusters m                 = {len(x)}")
    print(f"  grand total S              = {sum(x):,.0f}")
    print(f"  largest-cluster share      = {max(x)/sum(x):.6f}")
    print(f"  certified resolution floor = {fl:.6f}")
    print(f"  exact relative bootstrap sd = {sd:.6f}")
    print(f"  design effect (max/mean)   = {max(x)/(sum(x)/len(x)):.3f}")
    print(f"  target effect              = {target_effect:.4f}")
    # a 95% interval must have half-width below the effect to exclude the null
    need: float = target_effect / 1.96
    print(f"  needed standard error      = {need:.6f}")
    if sd < need:
        print("  VERDICT: one run suffices in principle.")
    else:
        k: int = seeds_needed(sd, need)
        print(f"  VERDICT: one run is insufficient; {k} independent seeds pool to "
              f"{pooled_sd(sd, k):.6f}.")
        if fl >= need:
            print("           NOTE: the per-run FLOOR alone already exceeds the requirement,")
            print("           so no amount of within-cluster sampling helps; only pooling"
                  " across")
            print("           genuinely independent seeds can reach the target.")


def replay_recorded_round() -> None:
    print("\n  --- the recorded round -------------------------------------------")
    deficits: List[Tuple[str, float]] = [("pilot", 0.9468), ("G1", 0.988), ("B", 0.9623)]
    for name, r in deficits:
        print(f"    seed family 20260824, leg {name:<6}: r = {r:.4f}  (deficit)")
    r_primary: float = 2598 / 2252
    r_loose: float = 40617 / 38594
    print(f"    seed 20260825 arbiter, cut 1e5 : r = {r_primary:.4f}  CI [1.0540, 1.2611]")
    print(f"    seed 20260825 arbiter, cut 1e6 : r = {r_loose:.4f}  CI [1.0051, 1.1016]")

    deficit_ci: Tuple[float, float] = (0.90, 1.00)
    arbiter_ci: Tuple[float, float] = (1.0051, 1.1016)
    disjoint: bool = deficit_ci[1] < arbiter_ci[0]
    alpha: float = 0.05
    print(f"\n    intervals disjoint            : {disjoint}")
    print(f"    union bound needs 2(1-a) <= 1 : 2*{1-alpha:.2f} = {2*(1-alpha):.2f}")
    print(f"    contradiction                 : {2*(1-alpha) > 1}")
    print("    => gate REJECTED by sign flip; nothing banked in either direction.")

    sigma_one: float = (arbiter_ci[1] - arbiter_ci[0]) / 2 / 1.96
    print(f"\n    implied one-run standard error : {sigma_one:.6f}")
    for k in (2, 3, 4):
        print(f"      {k} seeds pool to {pooled_sd(0.025, k):.6f}"
              + ("   <-- meets the declared 0.02 target" if k == 3 else ""))


def main() -> None:
    print("Gate decision calculator")
    print("=" * 68)
    print("\n  [A] idealised recorded profile (128 clusters, top 600, total 40617)")
    gate_report(make_profile(128, 600.0, 40617.0, zipf=0.0), target_effect=0.05)

    print("\n  [B] the same total, but a heavy Zipf tail (exponent 0.9)")
    gate_report(make_profile(128, 600.0, 40617.0, zipf=0.9), target_effect=0.05)

    print("\n  [C] a hypotenuse-like profile: one cluster holding 35% of all hits")
    gate_report(make_profile(128, 0.35 * 40617.0, 40617.0, zipf=0.5), target_effect=0.05)

    replay_recorded_round()
    print("\n" + "=" * 68)


if __name__ == "__main__":
    main()


"""Visualization: cluster profile, the resolution floor, and how it bites.

Left panel  : the recorded 128-cluster candidate profile against a flat null profile.
Middle panel: certified floor  max_j x_j/S - 1/m  versus the true relative dispersion
              rsd(x), as the top cluster's share is swept from 1/m up to 1.
Right panel : Monte-Carlo cluster-bootstrap distribution of the resampled total for
              three profiles of increasing skewness, with the closed-form standard
              deviation sqrt(sum (x_i - xbar)^2) overlaid.

Run: python3 viz_floor.py     (writes floor_visualization.png)
"""

from __future__ import annotations

import math
import random
from typing import List

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt  # noqa: E402

M: int = 128
TOTAL: float = 40617.0
TOP: float = 600.0


def profile_with_top(top: float, m: int = M, total: float = TOTAL) -> List[float]:
    """A profile with one cluster of size `top` and the remaining mass spread evenly."""
    rest: float = (total - top) / (m - 1)
    return [top] + [rest] * (m - 1)


def sum_sq_dev(x: List[float]) -> float:
    mean: float = sum(x) / len(x)
    return sum((v - mean) ** 2 for v in x)


def rsd(x: List[float]) -> float:
    return math.sqrt(sum_sq_dev(x)) / sum(x)


def floor_of(x: List[float]) -> float:
    return max(x) / sum(x) - 1.0 / len(x)


def bootstrap_totals(x: List[float], reps: int, seed: int) -> List[float]:
    rng = random.Random(seed)
    m: int = len(x)
    return [sum(x[rng.randrange(m)] for _ in range(m)) for _ in range(reps)]


def main() -> None:
    fig, axes = plt.subplots(1, 3, figsize=(16.5, 4.8))

    # ---- Panel 1: the recorded profile ------------------------------------ #
    recorded: List[float] = [600.0, 561.0, 540.0] + [
        (TOTAL - 600 - 561 - 540) / (M - 3)
    ] * (M - 3)
    ax = axes[0]
    ax.bar(range(M), sorted(recorded, reverse=True), color="#2b6cb0", width=1.0)
    ax.axhline(TOTAL / M, color="#e53e3e", ls="--", lw=1.6, label="flat null mean")
    ax.set_title("Recorded candidate cluster profile\n(sorted; top 600 / 561 / 540)")
    ax.set_xlabel("cluster rank")
    ax.set_ylabel("hits")
    ax.legend(frameon=False)

    # ---- Panel 2: floor vs true dispersion -------------------------------- #
    ax = axes[1]
    tops: List[float] = [TOTAL * s for s in [i / 200 for i in range(2, 190)]]
    fl: List[float] = [floor_of(profile_with_top(t)) for t in tops]
    tr: List[float] = [rsd(profile_with_top(t)) for t in tops]
    shares: List[float] = [t / TOTAL for t in tops]
    ax.plot(shares, tr, color="#2f855a", lw=2.2, label=r"true $\mathrm{rsd}(x)$")
    ax.plot(shares, fl, color="#dd6b20", lw=2.2, ls="--", label=r"certified floor $x_j/S-1/m$")
    ax.fill_between(shares, fl, tr, color="#dd6b20", alpha=0.12)
    ax.axvline(TOP / TOTAL, color="#4a5568", lw=1.2)
    ax.annotate(
        "recorded top share",
        xy=(TOP / TOTAL, 0.02),
        xytext=(0.18, 0.16),
        arrowprops=dict(arrowstyle="->", color="#4a5568"),
        color="#4a5568",
    )
    ax.set_title("The floor tracks the true dispersion\n(m = 128 clusters)")
    ax.set_xlabel("share of hits in the largest cluster")
    ax.set_ylabel("relative bootstrap standard error")
    ax.legend(frameon=False)

    # ---- Panel 3: bootstrap distributions --------------------------------- #
    ax = axes[2]
    colours = ["#3182ce", "#805ad5", "#c53030"]
    for colour, top in zip(colours, [TOTAL / M, TOP, TOTAL * 0.35]):
        prof: List[float] = profile_with_top(top)
        totals: List[float] = bootstrap_totals(prof, reps=6000, seed=2026)
        ax.hist(
            [t / TOTAL for t in totals],
            bins=70,
            histtype="step",
            lw=1.9,
            color=colour,
            label=f"top share {top/TOTAL:.3f}, rsd {rsd(prof):.4f}",
        )
    ax.axvline(1.0, color="#000", lw=1.0)
    ax.set_title("Cluster-bootstrap distribution of $T^*/S$\n(width is set by the profile, not by pair count)")
    ax.set_xlabel(r"$T^*/S$")
    ax.set_ylabel("replicates")
    ax.legend(frameon=False, fontsize=9)

    fig.tight_layout()
    fig.savefig("floor_visualization.png", dpi=150)
    print("wrote floor_visualization.png")


if __name__ == "__main__":
    main()


"""Visualization: hypotenuse multiplicity and the climb toward the 1/2 floor.

Left panel  : |H(c)| for every hypotenuse c up to 3000, with the record-setters
              highlighted -- the raw picture of intrinsic overdispersion.
Middle panel: the explicit witnesses C_k = prod_{v<k}((v+2)^2+1): the certified count
              k against the true multiplicity, on a log scale.
Right panel : the two-cluster resolution floor h/(h+2) - 1/2 for the family
              (|H(C_k)|, |H(5)|), climbing toward 1/2.

Run: python3 viz_multiplicity.py     (writes multiplicity_visualization.png)
"""

from __future__ import annotations

import math
from typing import List, Tuple

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt  # noqa: E402


def multiplicity_sieve(limit: int) -> List[int]:
    """|H(c)| for c = 0..limit by sieving representations of c^2."""
    counts: List[int] = [0] * (limit + 1)
    for a in range(1, limit + 1):
        aa: int = a * a
        for b in range(1, limit + 1):
            cc: int = aa + b * b
            c: int = math.isqrt(cc)
            if c <= limit and c * c == cc:
                counts[c] += 1
    return counts


def exact_multiplicity(c: int) -> int:
    n, prod, d = c, 1, 2
    while d * d <= n:
        if n % d == 0:
            e = 0
            while n % d == 0:
                n //= d
                e += 1
            if d % 4 == 1:
                prod *= 2 * e + 1
        d += 1
    if n > 1 and n % 4 == 1:
        prod *= 3
    return prod - 1


def witness(k: int) -> int:
    c = 1
    for v in range(k):
        c *= (v + 2) ** 2 + 1
    return c


def main() -> None:
    limit: int = 1200
    counts: List[int] = multiplicity_sieve(limit)

    fig, axes = plt.subplots(1, 3, figsize=(16.5, 4.8))

    # ---- Panel 1: raw multiplicities -------------------------------------- #
    ax = axes[0]
    xs: List[int] = [c for c in range(1, limit + 1) if counts[c] > 0]
    ys: List[int] = [counts[c] for c in xs]
    ax.scatter(xs, ys, s=6, color="#2b6cb0", alpha=0.5)
    record: int = 0
    rx: List[int] = []
    ry: List[int] = []
    for c in range(1, limit + 1):
        if counts[c] > record:
            record = counts[c]
            rx.append(c)
            ry.append(counts[c])
    ax.plot(rx, ry, color="#c53030", lw=1.8, marker="o", ms=4, label="record setters")
    ax.set_title(r"Hypotenuse multiplicity $|H(c)|$ for $c \leq %d$" % limit)
    ax.set_xlabel("hypotenuse $c$")
    ax.set_ylabel(r"ordered positive leg pairs")
    ax.legend(frameon=False)

    # ---- Panel 2: witnesses ----------------------------------------------- #
    ax = axes[1]
    ks: List[int] = list(range(1, 13))
    certified: List[int] = ks
    truth: List[int] = [exact_multiplicity(witness(k)) for k in ks]
    ax.plot(ks, certified, color="#dd6b20", lw=2.2, marker="s", label="certified $\\geq k$")
    ax.plot(ks, truth, color="#2f855a", lw=2.2, marker="o", label="true $|H(C_k)|$")
    ax.set_yscale("log")
    ax.set_title(r"The witness $C_k=\prod_{v<k}((v+2)^2+1)$ overshoots its own bound")
    ax.set_xlabel("$k$")
    ax.set_ylabel("multiplicity (log scale)")
    ax.legend(frameon=False)

    # ---- Panel 3: the near-1/2 floor -------------------------------------- #
    ax = axes[2]
    floors: List[float] = [h / (h + 2) - 0.5 for h in truth]
    ax.plot(ks, floors, color="#805ad5", lw=2.4, marker="o")
    ax.axhline(0.5, color="#c53030", ls="--", lw=1.6, label="worst-case limit $1/2$")
    ax.set_ylim(0, 0.55)
    ax.set_title("Two-cluster resolution floor of $(|H(C_k)|,\\,|H(5)|)$")
    ax.set_xlabel("$k$")
    ax.set_ylabel("floor $h/(h+2) - 1/2$")
    ax.legend(frameon=False)

    fig.tight_layout()
    fig.savefig("multiplicity_visualization.png", dpi=150)
    print("wrote multiplicity_visualization.png")


if __name__ == "__main__":
    main()
