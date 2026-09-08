"""
Measurable ceilings for content-only predictors: numerical demonstrations.
==========================================================================

Setting
-------
A finite population of observations.  Observation ``i`` carries a discrete
*content label* ``key[i]`` and a real *response* ``a[i]`` (in the motivating
application: a pooled train/test window, its key content, and its measured
importance).

A *content head* is any predictor of the form ``i -> f(key[i])``.  This class
contains every lookup table, every linear probe on any embedding of the label,
and every deep network applied to the label.

The central object is the ANOVA ceiling (the correlation ratio)

    eta2 = 1 - SS_within / SS_tot = SS_between / SS_tot,

which is the *exact maximum* of R^2 over the whole content-head class, attained
by the tabulated conditional mean.

This script demonstrates, with no external dependencies:

  1. The exact ceiling, and the identity SS_tot = SS_within + SS_between.
  2. The ceiling as a squared cosine (conditional mean = orthogonal projection:
     linear, idempotent, self-adjoint).
  3. The pair certificate: repeated-label gaps outweighing SS_tot prove that
     *no* content head reaches R^2 = 1/2.
  4. Exactness of the certificate in the two-observations-per-label design,
     and its completeness threshold: complete at fiber size 2, incomplete at 3.
  5. The dual refutation certificate from within-label ranges, with the
     explicit head it produces.
  6. The tunable family realizing every ceiling in [0, 1).
  7. Invariance under affine rescaling, relabelling, and replication.
  8. Coarsening monotonicity: depth on top of the content cannot help.
  9. The arithmetic of the motivating conjecture: 0.329 / 0.5 = 0.658 < 2/3,
     the exact repair threshold 0.4935, and the salvaged 65% guarantee.
"""

from __future__ import annotations

import itertools
import math
import random
from typing import Dict, Hashable, Iterable, List, Sequence, Tuple

Label = Hashable

# ----------------------------------------------------------------------------
# 1. Core statistics
# ----------------------------------------------------------------------------


def mean(values: Sequence[float]) -> float:
    """Arithmetic mean; 0.0 for the empty sequence (matching the convention
    that empty fibers contribute nothing)."""
    return sum(values) / len(values) if values else 0.0


def ss_tot(a: Sequence[float]) -> float:
    """Total dispersion  sum_i (a_i - grand mean)^2."""
    m = mean(a)
    return sum((x - m) ** 2 for x in a)


def fibers(key: Sequence[Label]) -> Dict[Label, List[int]]:
    """Group observation indices by their content label."""
    out: Dict[Label, List[int]] = {}
    for i, y in enumerate(key):
        out.setdefault(y, []).append(i)
    return out


def cond_means(key: Sequence[Label], a: Sequence[float]) -> Dict[Label, float]:
    """Conditional (fiberwise) means -- the optimal content head."""
    return {y: mean([a[i] for i in idx]) for y, idx in fibers(key).items()}


def ss_within(key: Sequence[Label], a: Sequence[float]) -> float:
    """Unexplainable dispersion: sum over fibers of the fiber's dispersion."""
    mu = cond_means(key, a)
    return sum((a[i] - mu[y]) ** 2 for y, idx in fibers(key).items() for i in idx)


def ss_between(key: Sequence[Label], a: Sequence[float]) -> float:
    """Explainable dispersion: sum_y |fiber_y| * (mu_y - grand mean)^2."""
    mu = cond_means(key, a)
    gm = mean(a)
    return sum(len(idx) * (mu[y] - gm) ** 2 for y, idx in fibers(key).items())


def anova_ceiling(key: Sequence[Label], a: Sequence[float]) -> float:
    """eta^2 = 1 - SS_within / SS_tot: the exact maximum of R^2 over all
    functions of the content label."""
    tot = ss_tot(a)
    if tot <= 0.0:
        raise ValueError("total dispersion must be positive")
    return 1.0 - ss_within(key, a) / tot


def r_squared(a: Sequence[float], pred: Sequence[float]) -> float:
    """Coefficient of determination of an arbitrary predictor."""
    tot = ss_tot(a)
    sse = sum((x - p) ** 2 for x, p in zip(a, pred))
    return 1.0 - sse / tot


def content_head(key: Sequence[Label], f: Dict[Label, float]) -> List[float]:
    """Materialise the content head  i -> f(key[i])."""
    return [f[y] for y in key]


# ----------------------------------------------------------------------------
# 2. Certificates
# ----------------------------------------------------------------------------


def best_pairs(key: Sequence[Label], a: Sequence[float]) -> Dict[Label, Tuple[int, int]]:
    """For each label seen at least twice, the pair of observations with the
    largest response gap (the fiber's argmin and argmax).  This is the optimal
    choice among one-pair-per-label certificates."""
    out: Dict[Label, Tuple[int, int]] = {}
    for y, idx in fibers(key).items():
        if len(idx) >= 2:
            lo = min(idx, key=lambda i: a[i])
            hi = max(idx, key=lambda i: a[i])
            out[y] = (lo, hi)
    return out


def pair_certificate(key: Sequence[Label], a: Sequence[float]) -> Tuple[bool, float, float]:
    """Confirming certificate.  Returns (fires, sum of squared gaps, SS_tot).

    If it fires, then eta^2 < 1/2 and EVERY content function has R^2 < 1/2.
    Uses only labels and responses -- no model of the predictor."""
    gaps = sum((a[i] - a[j]) ** 2 for (i, j) in best_pairs(key, a).values())
    tot = ss_tot(a)
    return gaps > tot, gaps, tot


def range_certificate(key: Sequence[Label], a: Sequence[float]) -> Tuple[bool, float, float]:
    """Refuting (Popoviciu-type) certificate.  Returns
    (fires, sum_y |fiber_y| * range_y^2, 2 * SS_tot).

    If it fires, then eta^2 >= 1/2 and the tabulated conditional mean is an
    explicit content head with R^2 >= 1/2."""
    total = 0.0
    for y, idx in fibers(key).items():
        vals = [a[i] for i in idx]
        total += len(idx) * (max(vals) - min(vals)) ** 2
    return total <= 2.0 * ss_tot(a), total, 2.0 * ss_tot(a)


def decide(key: Sequence[Label], a: Sequence[float]) -> str:
    """Run both certificates: 'confirmed', 'refuted' or 'undetermined'."""
    if pair_certificate(key, a)[0]:
        return "confirmed (no content head reaches R^2 = 1/2)"
    if range_certificate(key, a)[0]:
        return "refuted (the conditional mean already reaches R^2 >= 1/2)"
    return "undetermined by certificates"


# ----------------------------------------------------------------------------
# 3. Demonstrations
# ----------------------------------------------------------------------------


def banner(title: str) -> None:
    print()
    print("=" * 76)
    print(title)
    print("=" * 76)


def demo_decomposition() -> None:
    banner("1. The ANOVA decomposition and the exact maximum")
    key: List[Label] = ["a", "a", "b", "b", "c", "c", "c"]
    a: List[float] = [3.0, 5.0, -1.0, 0.0, 8.0, 6.0, 7.0]

    tot, within, between = ss_tot(a), ss_within(key, a), ss_between(key, a)
    print(f"responses          : {a}")
    print(f"labels             : {key}")
    print(f"conditional means  : {cond_means(key, a)}")
    print(f"SS_tot             = {tot:.6f}")
    print(f"SS_within          = {within:.6f}")
    print(f"SS_between         = {between:.6f}")
    print(f"identity check     : SS_within + SS_between = {within + between:.6f}")
    assert abs(tot - (within + between)) < 1e-9

    ceil = anova_ceiling(key, a)
    print(f"ceiling eta^2      = {ceil:.6f}   (= SS_between/SS_tot = {between / tot:.6f})")
    print(f"angle to content   = {math.degrees(math.acos(math.sqrt(ceil))):.3f} degrees "
          f"(45 degrees is the 1/2 threshold)")

    # The conditional mean attains the ceiling; random heads never beat it.
    mu = cond_means(key, a)
    print(f"R^2 of conditional mean = {r_squared(a, content_head(key, mu)):.6f}")
    rng = random.Random(20260907)
    best = max(
        r_squared(a, content_head(key, {y: rng.uniform(-10, 10) for y in mu}))
        for _ in range(20000)
    )
    print(f"best of 20000 random content heads = {best:.6f}  (never exceeds the ceiling)")
    assert best <= ceil + 1e-12


def demo_projection() -> None:
    banner("2. The conditional mean is an orthogonal projection")
    key: List[Label] = ["a", "a", "b", "b", "b", "c"]
    a: List[float] = [1.0, 4.0, -2.0, 0.5, 3.0, 7.0]
    b: List[float] = [0.0, -3.0, 2.0, 1.0, 5.0, -1.0]

    def project(v: Sequence[float]) -> List[float]:
        mu = cond_means(key, v)
        return [mu[y] for y in key]

    # linearity
    lhs = project([x + y for x, y in zip(a, b)])
    rhs = [x + y for x, y in zip(project(a), project(b))]
    print(f"linear      : max |P(a+b) - (Pa+Pb)| = {max(abs(x - y) for x, y in zip(lhs, rhs)):.2e}")

    # idempotence: depth stacked on the conditional mean gains nothing
    pa, ppa = project(a), project(project(a))
    print(f"idempotent  : max |P(Pa) - Pa|       = {max(abs(x - y) for x, y in zip(pa, ppa)):.2e}")

    # self-adjointness
    left = sum(x * y for x, y in zip(project(a), b))
    right = sum(x * y for x, y in zip(a, project(b)))
    print(f"self-adjoint: <Pa,b> = {left:.6f}   <a,Pb> = {right:.6f}")

    ceil = anova_ceiling(key, a)
    gm = mean(a)
    centred = [x - gm for x in a]
    proj_centred = [x - gm for x in project(a)]
    cos2 = sum(x * x for x in proj_centred) / sum(x * x for x in centred)
    print(f"squared cosine of the angle = {cos2:.6f} = ceiling {ceil:.6f}")
    assert abs(cos2 - ceil) < 1e-9


def demo_pair_certificate() -> None:
    banner("3. The pair certificate: ruling out an infinite class from data")
    # Two labels, two observations each, large within-label gaps.
    key: List[Label] = ["a", "a", "b", "b"]
    a: List[float] = [2.0, -2.0, 1.5, -1.0]
    fires, gaps, tot = pair_certificate(key, a)
    print(f"responses {a}, labels {key}")
    print(f"sum of squared repeated-label gaps = {gaps:.4f}")
    print(f"SS_tot                             = {tot:.4f}")
    print(f"certificate fires: {fires}")
    print(f"ceiling (computed independently)   = {anova_ceiling(key, a):.6f} < 0.5")

    # Exhaustive check that no content head reaches 1/2.
    rng = random.Random(7)
    worst = max(
        r_squared(a, content_head(key, {"a": rng.uniform(-5, 5), "b": rng.uniform(-5, 5)}))
        for _ in range(50000)
    )
    print(f"best R^2 over 50000 random content heads = {worst:.6f}  (< 0.5)")
    assert worst < 0.5

    # Exactness in the paired design: SS_within = half the sum of gaps.
    print(f"SS_within                          = {ss_within(key, a):.6f}")
    print(f"half the sum of gaps               = {gaps / 2:.6f}   (equal, by the paired-design "
          f"identity)")
    assert abs(ss_within(key, a) - gaps / 2) < 1e-9


def demo_completeness() -> None:
    banner("4. Completeness: exact at two observations per label, lossy at three")

    # (a) Three per label: ceiling below 1/2 but no certificate fires.
    key3: List[Label] = [0, 0, 0, 1, 1, 1]
    a3: List[float] = [-6.5, -0.5, -0.5, -1.5, 4.5, 4.5]
    fires, gaps, tot = pair_certificate(key3, a3)
    print("three observations per label:")
    print(f"  SS_within = {ss_within(key3, a3):.4f},  SS_tot = {tot:.4f}, "
          f"ceiling = {anova_ceiling(key3, a3):.6f} < 0.5")
    print(f"  best possible certificate value = {gaps:.4f} < {tot:.4f} -> fires: {fires}")
    assert anova_ceiling(key3, a3) < 0.5 and not fires

    # A brute-force sweep over ALL admissible one-pair-per-label choices.
    f = fibers(key3)
    best = max(
        (a3[p0] - a3[q0]) ** 2 + (a3[p1] - a3[q1]) ** 2
        for p0, q0 in itertools.product(f[0], f[0])
        for p1, q1 in itertools.product(f[1], f[1])
    )
    print(f"  exhaustive maximum over all pair choices = {best:.4f} (still below SS_tot)")
    assert best < tot

    # (b) One label, four alternating responses: ceiling 0, certificate silent.
    keyA: List[Label] = ["x", "x", "x", "x"]
    aA: List[float] = [1.0, -1.0, 1.0, -1.0]
    firesA, gapsA, totA = pair_certificate(keyA, aA)
    print("four observations, one label, responses 1,-1,1,-1:")
    print(f"  ceiling = {anova_ceiling(keyA, aA):.6f} (content explains nothing)")
    print(f"  largest squared gap = {gapsA:.4f}, SS_tot = {totA:.4f} -> fires: {firesA}")
    assert anova_ceiling(keyA, aA) == 0.0 and not firesA

    # (c) Two per label: whenever the ceiling is below 1/2 the certificate fires.
    rng = random.Random(11)
    checked = 0
    for _ in range(4000):
        n_labels = rng.randint(2, 5)
        key: List[Label] = []
        a: List[float] = []
        for y in range(n_labels):
            key += [y, y]
            a += [rng.uniform(-3, 3), rng.uniform(-3, 3)]
        if ss_tot(a) <= 1e-9:
            continue
        checked += 1
        assert (anova_ceiling(key, a) < 0.5) == pair_certificate(key, a)[0]
    print(f"paired design: certificate fires exactly when ceiling < 1/2, "
          f"verified on {checked} random populations")


def demo_refutation() -> None:
    banner("5. The dual certificate: refuting the bound, with the winning head")
    # Content-dominated population: labels far apart, tight within-label ranges.
    key: List[Label] = ["a", "a", "b", "b", "c", "c"]
    a: List[float] = [10.0, 10.4, -6.0, -5.7, 1.0, 0.8]
    fires, lhs, rhs = range_certificate(key, a)
    print(f"sum_y |fiber_y| * range_y^2 = {lhs:.4f}   2*SS_tot = {rhs:.4f}")
    print(f"refutation certificate fires: {fires}")
    ceil = anova_ceiling(key, a)
    mu = cond_means(key, a)
    print(f"ceiling = {ceil:.6f} >= 0.5")
    print(f"explicit head (conditional mean) = "
          f"{ {k: round(v, 4) for k, v in mu.items()} }")
    print(f"its R^2 = {r_squared(a, content_head(key, mu)):.6f}")
    assert fires and ceil >= 0.5

    print()
    print("full decision procedure on three populations:")
    for name, (k, v) in {
        "swap-dominated": (["a", "a", "b", "b"], [2.0, -2.0, 1.5, -1.0]),
        "content-dominated": (key, a),
        "three-per-label counterexample": ([0, 0, 0, 1, 1, 1], [-6.5, -0.5, -0.5, -1.5, 4.5, 4.5]),
    }.items():
        print(f"  {name:32s}: ceiling {anova_ceiling(k, v):.4f} -> {decide(k, v)}")


def quad_population(c: float, d: float) -> Tuple[List[Label], List[float]]:
    """Four observations, two labels, each label seen twice: content amplitude
    ``c`` and swap amplitude ``d``.  Its ceiling is exactly c^2/(c^2+d^2)."""
    return [0, 0, 1, 1], [c + d, c - d, -c - d, -c + d]


def demo_tunable_family() -> None:
    banner("6. Every ceiling in [0,1) occurs: the conjecture is not a theorem")
    print(f"{'c':>8} {'d':>8} {'SS_tot':>10} {'SS_within':>10} {'ceiling':>10} "
          f"{'c^2/(c^2+d^2)':>14}")
    for c, d in [(1.0, 0.0), (2.0, 1.0), (1.0, 1.0), (1.0, 2.0), (0.7, 1.0), (0.0, 1.0)]:
        key, a = quad_population(c, d)
        predicted = c * c / (c * c + d * d)
        print(f"{c:8.3f} {d:8.3f} {ss_tot(a):10.4f} {ss_within(key, a):10.4f} "
              f"{anova_ceiling(key, a):10.6f} {predicted:14.6f}")
        assert abs(anova_ceiling(key, a) - predicted) < 1e-12

    print()
    print("realising a prescribed ceiling rho via c = sqrt(rho), d = sqrt(1-rho):")
    for rho in [0.0, 0.125, 0.329, 0.4935, 0.5, 0.9, 0.99]:
        key, a = quad_population(math.sqrt(rho), math.sqrt(1.0 - rho))
        got = anova_ceiling(key, a) if ss_tot(a) > 0 else 0.0
        print(f"  requested {rho:7.4f}  ->  measured {got:.6f}   "
              f"[{decide(key, a)}]")
        assert abs(got - rho) < 1e-9
    print("Since every value in [0,1) is realised, no structural argument can bound")
    print("the ceiling below 1/2: it must be measured.")


def demo_invariance() -> None:
    banner("7. Invariance: units, labels, replication")
    key: List[Label] = ["p", "p", "q", "q", "q"]
    a: List[float] = [1.0, 2.5, -3.0, -1.0, 0.0]
    base = anova_ceiling(key, a)
    print(f"baseline ceiling                     = {base:.10f}")

    scaled = [3.7 * x - 12.0 for x in a]
    print(f"after a -> 3.7*a - 12                = {anova_ceiling(key, scaled):.10f}")
    assert abs(anova_ceiling(key, scaled) - base) < 1e-12

    renamed: List[Label] = [{"p": "TOKEN_9f", "q": "TOKEN_0a"}[y] for y in key]
    print(f"after an injective relabelling       = {anova_ceiling(renamed, a):.10f}")
    assert abs(anova_ceiling(renamed, a) - base) < 1e-12

    k = 4
    rep_key: List[Label] = [y for y in key for _ in range(k)]
    rep_a: List[float] = [x for x in a for _ in range(k)]
    print(f"after 4-fold replication             = {anova_ceiling(rep_key, rep_a):.10f}")
    print(f"  (SS_tot {ss_tot(a):.4f} -> {ss_tot(rep_a):.4f}, "
          f"SS_within {ss_within(key, a):.4f} -> {ss_within(rep_key, rep_a):.4f})")
    assert abs(anova_ceiling(rep_key, rep_a) - base) < 1e-12


def demo_coarsening() -> None:
    banner("8. Coarsening monotonicity: depth on top of the content cannot help")
    key: List[Label] = ["a", "a", "b", "b", "c", "c"]
    a: List[float] = [4.0, 3.0, 1.0, 0.5, -3.0, -4.0]
    print(f"raw content ceiling                       = {anova_ceiling(key, a):.6f}")
    for name, g in {
        "merge b and c": {"a": "A", "b": "BC", "c": "BC"},
        "merge a and b": {"a": "AB", "b": "AB", "c": "C"},
        "collapse everything": {"a": "*", "b": "*", "c": "*"},
    }.items():
        coarse: List[Label] = [g[y] for y in key]
        print(f"  after '{name}': {anova_ceiling(coarse, a):.6f}")
        assert anova_ceiling(coarse, a) <= anova_ceiling(key, a) + 1e-12
    print("Every derived feature of the label (hash, bucket, embedding, bottleneck)")
    print("is such a map, so the raw content ceiling dominates the whole tower.")


def demo_conjecture_arithmetic() -> None:
    banner("9. The conjecture's arithmetic: 0.329 against the ceiling")
    measured = 0.329
    print(f"{'ceiling':>10} {'captured fraction':>20} {'> 2/3?':>10} {'> 65%?':>10}")
    for ceil in [0.35, 0.40, 0.45, 0.4935, 0.4936, 0.50, 0.60, 0.90]:
        frac = measured / ceil
        print(f"{ceil:10.4f} {frac:20.6f} {str(frac > 2 / 3):>10} {str(frac > 0.65):>10}")
    print()
    print(f"at the conjecture's own boundary: 0.329/0.5 = {measured / 0.5:.6f} "
          f"< 2/3 = {2 / 3:.6f}   -> the 'two thirds' clause is FALSE there")
    print(f"exact repair threshold: 0.329/(2/3) = {measured / (2 / 3):.6f}")
    print("salvaged statement: for any ceiling in (0, 0.5] the measured value")
    print(f"captures more than 65% (worst case {measured / 0.5:.4f}).")
    assert measured / 0.5 < 2 / 3
    assert abs(measured / (2 / 3) - 0.4935) < 1e-9
    assert measured / 0.5 > 0.65


def demo_pooled_tradeoff() -> None:
    banner("10. The pooled population and the asymmetric trade-off")
    # importance[w][i] for windows w and contents i
    importance: List[List[float]] = [
        [0.90, 0.20, -0.40, 0.10],
        [0.70, 0.35, -0.55, 0.05],
        [1.05, 0.15, -0.35, 0.20],
    ]
    n_windows = len(importance)
    n_contents = len(importance[0])
    key: List[Label] = [i for i in range(n_contents) for _ in range(n_windows)]
    a: List[float] = [importance[w][i] for i in range(n_contents) for w in range(n_windows)]

    avg = [mean([importance[w][i] for w in range(n_windows)]) for i in range(n_contents)]
    dispersion = sum(
        (importance[w][i] - avg[i]) ** 2 for i in range(n_contents) for w in range(n_windows)
    )
    print(f"across-window average importances = {[round(x, 4) for x in avg]}")
    print(f"context dispersion  sum_i sum_w (a_w(i) - avg_i)^2 = {dispersion:.6f}")
    print(f"SS_within of the pooled population                = {ss_within(key, a):.6f}")
    print("  (these are identically the same quantity)")
    assert abs(dispersion - ss_within(key, a)) < 1e-12

    ceil = anova_ceiling(key, a)
    tot = ss_tot(a)
    print(f"pooled ceiling = {ceil:.6f}")
    if ceil >= 0.5:
        B = 2
        bound = math.sqrt(B * tot / (2 * n_windows))
        print(f"the ceiling is at least 1/2, so the relational deficit is at most "
              f"sqrt(B*SS_tot/(2|W|)) = {bound:.6f} for B = {B}")
        print("the two arms cannot both be binding.")


def main() -> None:
    demo_decomposition()
    demo_projection()
    demo_pair_certificate()
    demo_completeness()
    demo_refutation()
    demo_tunable_family()
    demo_invariance()
    demo_coarsening()
    demo_conjecture_arithmetic()
    demo_pooled_tradeoff()
    print()
    print("All demonstrations completed and all assertions passed.")


if __name__ == "__main__":
    main()
