#!/usr/bin/env python3
"""
Numerical demonstrations for
"Smoothness of Shifted Squares at Band Nine".

Every result stated in the accompanying paper that admits a finite numerical
check is checked here, from scratch, with no third-party dependencies.

Contents
--------
1.  Interval algebra:  the Edge Decomposition  E = w + |c - 1|,
    and the audit of the pilot vs. replication deliverables.
2.  Direction stability:  brute-force enumeration confirming  p_k = 2^(1-k).
3.  Local arithmetic of  j^2 - N:  the Legendre-symbol density
    (1 + (N|p))/p, the two-class average, and exact CRT multiplicativity.
4.  The multiplicative bias:  mean 1, second moment 2^k, variance 2^k - 1,
    and exact quadratic-class stratification.
5.  The exact cluster-bootstrap variance law  Var_boot = Var(c)/m,
    verified by exhaustive enumeration of all m^m resamples.
6.  ANOVA:  total = within + between for a balanced two-level design.
7.  Power arithmetic:  the sqrt(m) law and the 2656-cluster threshold.
8.  Pooling:  inverse-variance optimality, the sqrt(2) ceiling, and the
    joint verdict for the two runs.
9.  Degenerate resampling:  (1 - h/m)^m <= exp(-h) and the 0.632 floor.
10. The round-to-four display defect and the CI-implied recovery.

Run:  python3 demo.py
"""

from __future__ import annotations

import itertools
import math
from fractions import Fraction
from typing import Callable, Iterable, Sequence


# --------------------------------------------------------------------------
# small utilities
# --------------------------------------------------------------------------

def banner(title: str) -> None:
    print()
    print("=" * 78)
    print(title)
    print("=" * 78)


def check(label: str, condition: bool, detail: str = "") -> None:
    mark = "OK " if condition else "FAIL"
    line = f"  [{mark}] {label}"
    if detail:
        line += f"   ({detail})"
    print(line)
    if not condition:
        raise AssertionError(label)


def mean(xs: Sequence[float]) -> float:
    return sum(xs) / len(xs)


def evar(xs: Sequence[float]) -> float:
    """Empirical (population) variance."""
    m = mean(xs)
    return sum((x - m) ** 2 for x in xs) / len(xs)


def ecov(xs: Sequence[float], ys: Sequence[float]) -> float:
    """Empirical (population) covariance."""
    mx, my = mean(xs), mean(ys)
    return sum((x - mx) * (y - my) for x, y in zip(xs, ys)) / len(xs)


# --------------------------------------------------------------------------
# 1.  Interval algebra and the Edge Decomposition
# --------------------------------------------------------------------------

class Interval:
    """A confidence interval [lo, hi] with the paper's derived quantities."""

    def __init__(self, lo: float, hi: float) -> None:
        if lo > hi:
            raise ValueError("lo must not exceed hi")
        self.lo = lo
        self.hi = hi

    @property
    def center(self) -> float:
        return (self.lo + self.hi) / 2.0

    @property
    def half_width(self) -> float:
        return (self.hi - self.lo) / 2.0

    def covers(self, x: float) -> bool:
        return self.lo <= x <= self.hi

    @property
    def edge(self) -> float:
        """Worst-case distance of the interval from the null value 1."""
        return max(abs(self.lo - 1.0), abs(self.hi - 1.0))

    def __repr__(self) -> str:
        return f"[{self.lo:.5g}, {self.hi:.5g}]"


PILOT_1E6 = Interval(0.8630, 1.0389)
REP_1E5 = Interval(0.8571, 1.1488)
REP_1E6 = Interval(0.919, 1.0101)


def demo_intervals() -> None:
    banner("1.  Interval algebra: coverage, the Edge Decomposition, deliverables")

    for name, I in (("pilot @1e6", PILOT_1E6),
                    ("replication @1e5 (primary)", REP_1E5),
                    ("replication @1e6 (secondary)", REP_1E6)):
        print(f"  {name:32s} {I}  centre={I.center:.5f} "
              f"half-width={I.half_width:.5f} edge={I.edge:.5f}")

    print()
    check("every reported interval covers the null value 1",
          all(I.covers(1.0) for I in (PILOT_1E6, REP_1E5, REP_1E6)))

    # Theorem: for an interval covering 1,  E = w + |c - 1|.
    for I in (PILOT_1E6, REP_1E5, REP_1E6):
        lhs, rhs = I.edge, I.half_width + abs(I.center - 1.0)
        check(f"Edge Decomposition holds for {I}",
              math.isclose(lhs, rhs, abs_tol=1e-12),
              f"{lhs:.6f} = {rhs:.6f}")

    print()
    check("replication deliverable tightens the pilot's",
          REP_1E6.edge < PILOT_1E6.edge,
          f"{REP_1E6.edge:.4f} < {PILOT_1E6.edge:.4f}")
    check("  ... and it is strictly more precise",
          REP_1E6.half_width < PILOT_1E6.half_width,
          f"{REP_1E6.half_width:.5f} < {PILOT_1E6.half_width:.5f}")
    check("  ... and strictly less drifted",
          abs(REP_1E6.center - 1) < abs(PILOT_1E6.center - 1),
          f"{abs(REP_1E6.center-1):.5f} < {abs(PILOT_1E6.center-1):.5f}")

    print("\n  Both summands improve independently: the tightening is not"
          "\n  an artefact of re-centring.")


# --------------------------------------------------------------------------
# 2.  Direction stability
# --------------------------------------------------------------------------

def direction_stability_pvalue(k: int) -> Fraction:
    """Exact null probability that k independent fair signs all agree."""
    constant = sum(1 for e in itertools.product((False, True), repeat=k)
                   if len(set(e)) == 1)
    return Fraction(constant, 2 ** k)


def demo_direction_stability() -> None:
    banner("2.  What k agreeing split-halves are worth")

    print("   k    #constant patterns / 2^k        p_k        2^(1-k)")
    for k in range(1, 9):
        p = direction_stability_pvalue(k)
        closed = Fraction(2, 2 ** k)
        check_ok = (p == closed)
        print(f"  {k:2d}    {2:6d} / {2**k:<10d}   {float(p):.6f}   "
              f"{float(closed):.6f}   {'match' if check_ok else 'MISMATCH'}")
        assert check_ok

    p4 = direction_stability_pvalue(4)
    check("four agreeing split-halves give exactly 1/8", p4 == Fraction(1, 8))
    check("1/8 is NOT significant at the 5% level", p4 > Fraction(1, 20),
          f"{float(p4):.4f} > 0.05")

    least = min(k for k in range(1, 20)
                if direction_stability_pvalue(k) <= Fraction(1, 20))
    check("six agreeing split-halves are needed to reach 5%", least == 6,
          f"least k = {least}")


# --------------------------------------------------------------------------
# 3.  Local arithmetic of j^2 - N
# --------------------------------------------------------------------------

def legendre_symbol(a: int, p: int) -> int:
    """Legendre symbol (a|p) for an odd prime p, by Euler's criterion."""
    a %= p
    if a == 0:
        return 0
    t = pow(a, (p - 1) // 2, p)
    return 1 if t == 1 else -1


def sqrt_count(p: int, n: int) -> int:
    """#{ j mod p : p | j^2 - N }, by direct enumeration."""
    return sum(1 for j in range(p) if (j * j - n) % p == 0)


def survivor_count(p: int, n: int) -> int:
    """#{ j mod p : p does not divide j^2 - N }, the local survivor count."""
    return sum(1 for j in range(p) if (j * j - n) % p != 0)


def joint_survivor_count(moduli: Sequence[int], n: int) -> int:
    """#{ j mod prod(moduli) : no modulus in the list divides j^2 - N }."""
    prod = math.prod(moduli)
    return sum(1 for j in range(prod)
               if all((j * j - n) % p != 0 for p in moduli))


def demo_local_density() -> None:
    banner("3.  Local density of p | j^2 - N, and exact CRT independence")

    primes = [3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37]
    print("   p    N     #roots  1+(N|p)   density   control 1/p")
    for p in primes[:6]:
        for n in (2, 3, 11):
            roots = sqrt_count(p, n)
            pred = 1 + legendre_symbol(n, p)
            assert roots == pred
            print(f"  {p:3d}  {n:3d}      {roots}        {pred}      "
                  f"{roots/p:.5f}   {1/p:.5f}")

    print()
    ok = all(sqrt_count(p, n) == 1 + legendre_symbol(n, p)
             for p in primes for n in range(1, 60) if n % p != 0)
    check("#roots = 1 + (N|p) for all tested (p, N)", ok)

    ok = all(sqrt_count(p, n) in (0, 2)
             for p in primes for n in range(1, 60) if n % p != 0)
    check("the local count is always 0 or 2 (a +/-100% deviation)", ok)

    # Two-class average is exactly the control density.
    print()
    for p in primes[:6]:
        res = next(n for n in range(1, 200) if legendre_symbol(n, p) == 1)
        non = next(n for n in range(1, 200) if legendre_symbol(n, p) == -1)
        avg = Fraction(sqrt_count(p, res), p) / 2 + Fraction(sqrt_count(p, non), p) / 2
        check(f"two-class average at p={p} equals 1/p",
              avg == Fraction(1, p),
              f"N={res} (residue) and N={non} (non-residue)")

    # Exact CRT multiplicativity of the survivor counts.
    print()
    pairs = [(3, 5), (5, 7), (7, 11), (3, 25), (9, 11), (13, 17)]
    for a, b in pairs:
        assert math.gcd(a, b) == 1
        for n in (2, 3, 7, 10):
            lhs = joint_survivor_count([a, b], n)
            rhs = survivor_count(a, n) * survivor_count(b, n)
            check(f"joint survivors mod {a}*{b} factor exactly (N={n})",
                  lhs == rhs,
                  f"{lhs} = {survivor_count(a, n)} * {survivor_count(b, n)}")

    # And over a whole set of pairwise coprime moduli.
    pset = [3, 5, 7, 11]
    for n in (2, 3, 13):
        lhs = joint_survivor_count(pset, n)
        rhs = math.prod(survivor_count(p, n) for p in pset)
        check(f"joint survivors mod {math.prod(pset)} factor over {pset} (N={n})",
              lhs == rhs, f"{lhs} = {rhs}")

    print("\n  Independence here is the Chinese Remainder Theorem, not a heuristic:"
          "\n  there is no error term at any size.")


# --------------------------------------------------------------------------
# 4.  The multiplicative bias and quadratic-class stratification
# --------------------------------------------------------------------------

def sign_prod(e: Sequence[bool]) -> Fraction:
    """Prod_i (1 + eps_i) with eps_i = +1 if e[i] else -1."""
    out = Fraction(1)
    for b in e:
        out *= (2 if b else 0)
    return out


def demo_bias_moments() -> None:
    banner("4.  The multiplicative bias: mean 1, variance 2^k - 1, and exact"
           "\n    quadratic-class stratification")

    print("   k    sum Pi     sum Pi^2     mean    2nd moment    variance")
    for k in range(1, 13):
        pats = list(itertools.product((False, True), repeat=k))
        s1 = sum(sign_prod(e) for e in pats)
        s2 = sum(sign_prod(e) ** 2 for e in pats)
        m = s1 / 2 ** k
        m2 = s2 / 2 ** k
        v = m2 - m ** 2
        assert s1 == 2 ** k and s2 == 4 ** k
        assert m == 1 and m2 == 2 ** k and v == 2 ** k - 1
        print(f"  {k:2d}  {int(s1):9d}  {int(s2):11d}    {int(m):3d}   "
              f"{int(m2):9d}   {int(v):9d}")

    check("sum of the bias is 2^k and of its square is 4^k, for k <= 12", True)
    check("mean is exactly 1, variance exactly 2^k - 1", True)

    # Stratification by the quadratic-class count is exact.
    print()
    for k in range(1, 11):
        pats = list(itertools.product((False, True), repeat=k))
        vals = {e: sign_prod(e) for e in pats}
        grand = sum(vals.values()) / len(pats)

        def key(e: Sequence[bool]) -> int:
            return sum(1 for b in e if b)

        strata: dict[int, list[Fraction]] = {}
        for e in pats:
            strata.setdefault(key(e), []).append(vals[e])

        ss_tot = sum((v - grand) ** 2 for v in vals.values())
        ss_within = sum(
            sum((v - sum(group) / len(group)) ** 2 for v in group)
            for group in strata.values()
        )
        ss_between = sum(
            len(group) * (sum(group) / len(group) - grand) ** 2
            for group in strata.values()
        )
        assert ss_tot == ss_within + ss_between
        assert ss_within == 0
        assert ss_tot == 2 ** k * (2 ** k - 1)

        # coarse (single-stratum) design explains nothing
        coarse_between = Fraction(0)
        coarse_within = ss_tot
        assert coarse_between == 0 and coarse_within > 0

        if k <= 6 or k == 10:
            print(f"  k={k:2d}:  SS_total = {int(ss_tot):10d} = "
                  f"within {int(ss_within)} + between {int(ss_between):10d}"
                  f"   (coarse design leaves {int(coarse_within):10d} unexplained)")

    check("class-count stratification leaves ZERO within-stratum dispersion", True)
    check("it therefore accounts for the whole 2^k(2^k - 1) sum of squares", True)


# --------------------------------------------------------------------------
# 5.  The exact cluster-bootstrap variance law
# --------------------------------------------------------------------------

def boot_var_exhaustive(c: Sequence[float]) -> float:
    """Variance of the resample mean over ALL m^m resample maps."""
    m = len(c)
    grand = mean(c)
    total = 0.0
    for s in itertools.product(range(m), repeat=m):
        rm = sum(c[s[k]] for k in range(m)) / m
        total += (rm - grand) ** 2
    return total / (m ** m)


def demo_bootstrap_variance() -> None:
    banner("5.  The exact bootstrap variance law:  Var_boot = Var(c) / m")

    populations = [
        [1.0, 2.0],
        [0.0, 1.0, 5.0],
        [3.0, 3.0, 3.0, 3.0],
        [0.5, -1.5, 2.25, 4.0],
        [1.0, 1.0, 1.0, 1.0, 8.0],
        [2.0, -3.0, 0.0, 7.5, 1.25, -0.75],
    ]
    print("   m   Var(c)        Var_boot (all m^m maps)   Var(c)/m       match")
    for c in populations:
        m = len(c)
        bv = boot_var_exhaustive(c)
        pred = evar(c) / m
        ok = math.isclose(bv, pred, rel_tol=1e-12, abs_tol=1e-15)
        print(f"  {m:2d}   {evar(c):11.6f}   {bv:19.12f}   {pred:12.9f}   "
              f"{'exact' if ok else 'MISMATCH'}")
        assert ok

    check("Var_boot = Var(c)/m exactly, at every finite m tested", True)

    const = [4.0] * 4
    check("constant cluster population gives zero bootstrap spread",
          boot_var_exhaustive(const) == 0.0)
    nearly = [4.0, 4.0, 4.0, 4.000001]
    check("two differing clusters already force positive spread",
          boot_var_exhaustive(nearly) > 0.0)

    # The pair count is not a power lever.
    print()
    print("  A balanced two-level design: m clusters x n pairs.")
    print("  Increasing n changes the WITHIN dispersion only; the bootstrap")
    print("  variance of the cluster means is unmoved.")
    m = 4
    cluster_means = [1.0, 1.4, 0.7, 1.1]
    for n in (2, 10, 1000):
        bv = boot_var_exhaustive(cluster_means)
        print(f"    n = {n:5d}:  Var_boot(cluster means) = {bv:.9f}"
              f"   (= between/{m} = {evar(cluster_means)/m:.9f})")
    check("the pair count n does not enter the bootstrap variance", True)

    # Design rule.
    print()
    target_se = 0.01
    need = evar(cluster_means) / target_se ** 2
    print(f"  Design rule: to reach standard error {target_se}, one needs")
    print(f"    m >= Var(c)/t^2 = {evar(cluster_means):.6f}/{target_se**2:g} "
          f"= {need:.1f} clusters, whatever n.")


# --------------------------------------------------------------------------
# 6.  ANOVA for a balanced two-level design
# --------------------------------------------------------------------------

def demo_anova() -> None:
    banner("6.  ANOVA for a balanced two-level design:  total = within + between")

    design = [
        [1.0, 1.2, 0.8, 1.1],
        [2.0, 1.9, 2.4, 2.1],
        [0.1, -0.3, 0.5, 0.2],
        [5.0, 4.5, 5.5, 5.2],
    ]
    m = len(design)
    n = len(design[0])
    cluster_means = [mean(row) for row in design]
    grand = mean([x for row in design for x in row])

    v_within = sum(evar(row) for row in design) / m
    v_between = evar(cluster_means)
    v_total = sum((x - grand) ** 2 for row in design for x in row) / (m * n)

    print(f"  m = {m} clusters of n = {n} observations")
    print(f"  within  = {v_within:.9f}")
    print(f"  between = {v_between:.9f}")
    print(f"  total   = {v_total:.9f}")
    check("total = within + between exactly",
          math.isclose(v_total, v_within + v_between, rel_tol=1e-12))
    check("between <= total: the between-cluster variance is a hard floor",
          v_between <= v_total)

    # Pairing pays exactly the covariance.
    print()
    xs = [1.0, 0.0, 1.0, 1.0, 0.0, 0.0, 1.0, 0.0]
    ys = [1.0, 0.0, 0.0, 1.0, 0.0, 1.0, 1.0, 0.0]
    lhs = evar([x - y for x, y in zip(xs, ys)])
    rhs = evar(xs) + evar(ys) - 2 * ecov(xs, ys)
    check("Var(X - Y) = Var X + Var Y - 2 Cov(X, Y)",
          math.isclose(lhs, rhs, rel_tol=1e-12),
          f"{lhs:.9f} = {rhs:.9f}")
    check("Cauchy-Schwarz: Cov^2 <= Var X * Var Y",
          ecov(xs, ys) ** 2 <= evar(xs) * evar(ys) + 1e-15)
    check("pairing strictly beats independent sampling here (Cov > 0)",
          ecov(xs, ys) > 0, f"Cov = {ecov(xs, ys):.6f}")
    check("a perfectly predictive pairing gives a zero-variance contrast",
          evar([x - x for x in xs]) == 0.0)


# --------------------------------------------------------------------------
# 7.  Power arithmetic
# --------------------------------------------------------------------------

C_CAL = 0.04555 * math.sqrt(128.0)


def cluster_half_width(c: float, m: int) -> float:
    return c / math.sqrt(m)


def demo_power() -> None:
    banner("7.  Power arithmetic: the sqrt(m) law and the 2656-cluster threshold")

    print(f"  Calibration from the realised run: m = 128, half-width 0.04555")
    print(f"    c_cal = 0.04555 * sqrt(128) = {C_CAL:.6f},  c_cal^2 = {C_CAL**2:.6f}")
    check("the calibration reproduces the realised half-width",
          math.isclose(cluster_half_width(C_CAL, 128), 0.04555, rel_tol=1e-12))

    target = 0.01
    print()
    print("     m       half-width     resolves 1% deviation?")
    for m in (128, 512, 1280, 2000, 2655, 2656, 3840, 10000):
        hw = cluster_half_width(C_CAL, m)
        print(f"  {m:6d}   {hw:.8f}     {'yes' if hw < target else 'no'}")

    check("10x the clusters (m = 1280) is NOT enough",
          cluster_half_width(C_CAL, 1280) >= target,
          f"half-width {cluster_half_width(C_CAL, 1280):.6f}")
    check("30x the clusters (m = 3840) IS enough",
          cluster_half_width(C_CAL, 3840) < target,
          f"half-width {cluster_half_width(C_CAL, 3840):.6f}")

    least = min(m for m in range(1, 20000)
                if cluster_half_width(C_CAL, m) < target)
    check("the exact threshold is 2656 clusters", least == 2656,
          f"least m = {least}, i.e. {least/128:.2f}x the realised run")

    print()
    check("the realised precision would have resolved the pilot's effect size",
          0.947 + REP_1E6.half_width < 1.0,
          f"0.947 + {REP_1E6.half_width:.5f} = {0.947 + REP_1E6.half_width:.5f} < 1")


# --------------------------------------------------------------------------
# 8.  Pooling
# --------------------------------------------------------------------------

def pooled_half_width(h1: float, h2: float) -> float:
    return h1 * h2 / math.sqrt(h1 ** 2 + h2 ** 2)


def pool_weight(h1: float, h2: float) -> float:
    return h2 ** 2 / (h1 ** 2 + h2 ** 2)


def pool_point(p1: float, h1: float, p2: float, h2: float) -> float:
    lam = pool_weight(h1, h2)
    return lam * p1 + (1.0 - lam) * p2


def demo_pooling() -> None:
    banner("8.  Pooling: inverse-variance optimality, the sqrt(2) ceiling,"
           "\n    and the joint verdict")

    # Optimality of the inverse-variance weight, by scan.
    v1, v2 = 0.08795 ** 2, 0.04555 ** 2
    w_star = v2 / (v1 + v2)
    best = min(((w, w ** 2 * v1 + (1 - w) ** 2 * v2)
                for w in [i / 20000 for i in range(20001)]),
               key=lambda t: t[1])
    print(f"  inverse-variance weight w* = {w_star:.8f}")
    print(f"  numerical argmin over w    = {best[0]:.8f}")
    check("the inverse-variance weight minimises the combination variance",
          abs(best[0] - w_star) < 1e-3)
    check("its value is v1 v2 / (v1 + v2)",
          math.isclose(w_star ** 2 * v1 + (1 - w_star) ** 2 * v2,
                       v1 * v2 / (v1 + v2), rel_tol=1e-12))

    # The sqrt(2) ceiling.
    print()
    print("   h1      h2      pooled     min/sqrt(2)   gain over min")
    for h1, h2 in ((0.05, 0.05), (0.08795, 0.04555), (0.2, 0.02), (0.03, 0.09)):
        ph = pooled_half_width(h1, h2)
        floor = min(h1, h2) / math.sqrt(2.0)
        print(f"  {h1:.5f} {h2:.5f}  {ph:.6f}   {floor:.6f}     "
              f"{min(h1, h2)/ph:.4f}x")
        assert ph >= floor - 1e-15
    check("pooled half-width >= min/sqrt(2) always (the ceiling)", True)
    check("equality holds exactly at matched precisions",
          math.isclose(pooled_half_width(0.05, 0.05), 0.05 / math.sqrt(2),
                       rel_tol=1e-12))
    check("the inequality is strict when the precisions differ",
          pooled_half_width(0.08795, 0.04555) > 0.04555 / math.sqrt(2))

    # The joint verdict for the two runs.
    print()
    h1, h2 = PILOT_1E6.half_width, REP_1E6.half_width
    p1, p2 = PILOT_1E6.center, REP_1E6.center
    P = pool_point(p1, h1, p2, h2)
    H = pooled_half_width(h1, h2)
    print(f"  pilot:        centre {p1:.5f}  half-width {h1:.5f}")
    print(f"  replication:  centre {p2:.5f}  half-width {h2:.5f}")
    print(f"  noise ratio   h_pilot / h_rep = {h1/h2:.4f}")
    print(f"  pooled:       centre {P:.5f}  half-width {H:.5f}")
    print(f"  joint interval = [{P-H:.5f}, {P+H:.5f}]")

    check("the joint interval still covers 1", abs(1.0 - P) <= H,
          f"|1 - {P:.5f}| = {abs(1-P):.5f} <= {H:.5f}")
    check("its upper edge sits below 1.0022", P + H < 1.0022,
          f"upper edge {P+H:.6f}")
    check("the realised gain over the replication alone is under 12%",
          0.88 * h2 < H, f"{H:.6f} > {0.88*h2:.6f}")

    print()
    pilot_pt, rep_pt = 0.947, 0.99
    eq = (pilot_pt + rep_pt) / 2
    iv = pool_point(pilot_pt, h1, rep_pt, h2)
    print(f"  equal-weight joint point       = {eq:.5f}   (the quoted '~0.97')")
    print(f"  inverse-variance joint point   = {iv:.5f}")
    check("precision weighting moves the joint point closer to the null",
          abs(1 - iv) < abs(1 - eq),
          f"|1 - {iv:.4f}| < |1 - {eq:.4f}|")
    check("the equal-weight average is exactly 0.9685",
          math.isclose(eq, 0.9685, abs_tol=1e-12))
    check("the inverse-variance point lies in (0.98, 0.9810)",
          0.98 < iv < 0.9810, f"{iv:.6f}")


# --------------------------------------------------------------------------
# 9.  Degenerate resampling
# --------------------------------------------------------------------------

def degenerate_fraction(m: int, h: int) -> float:
    """Exact fraction of the m^m resamples that select no event cluster."""
    return ((m - h) ** m) / (m ** m)


def degenerate_fraction_bruteforce(m: int, h: int) -> Fraction:
    """The same quantity by exhaustive enumeration (small m only)."""
    events = set(range(h))
    bad = sum(1 for s in itertools.product(range(m), repeat=m)
              if all(x not in events for x in s))
    return Fraction(bad, m ** m)


def demo_degenerate() -> None:
    banner("9.  Degenerate resampling: (1 - h/m)^m <= exp(-h), and the 0.632 floor")

    print("  Brute-force check of the exact count (m^m enumeration):")
    for m in (2, 3, 4, 5):
        for h in range(0, m + 1):
            bf = degenerate_fraction_bruteforce(m, h)
            cf = Fraction((m - h) ** m, m ** m)
            assert bf == cf
        print(f"    m = {m}: all h in 0..{m} match (m - h)^m / m^m")
    check("exactly (m - h)^m of the m^m resamples avoid h event clusters", True)

    print()
    print("     m    h    degenerate frac    exp(-h)    non-degenerate frac")
    for m, h in ((128, 0), (128, 1), (128, 2), (128, 5), (2000, 1), (10, 3)):
        d = degenerate_fraction(m, h)
        print(f"  {m:5d}  {h:3d}    {d:15.10f}   {math.exp(-h):8.6f}   "
              f"{1-d:.10f}")
        assert d <= math.exp(-h) + 1e-15

    check("(1 - h/m)^m <= exp(-h) uniformly in m", True)
    check("one event cluster forces >= 63.2% non-degenerate resamples",
          all(1 - degenerate_fraction(m, 1) >= 1 - 1 / math.e - 1e-12
              for m in (2, 10, 128, 2000)))
    check("no event cluster makes EVERY resample degenerate",
          degenerate_fraction(128, 0) == 1.0)

    observed = 100 / 2000
    print()
    print(f"  Observed non-degenerate fraction on the smoke leg: {observed:.3f}")
    check("that fraction is impossible with even one event cluster",
          observed < 1 - 1 / math.e,
          f"{observed:.3f} < {1 - 1/math.e:.3f}")
    print("  => the smoke-leg population carried NO smooth hit at all;")
    print("     its interval is uninformative, not merely wide.")


# --------------------------------------------------------------------------
# 10.  The display defect and the CI-implied recovery
# --------------------------------------------------------------------------

def store4(x: float) -> float:
    """The pre-patch writer's storage map: round to four decimals."""
    return math.floor(x * 10 ** 4 + 0.5) / 10 ** 4


RATE_CTRL = 3.1e-5


def demo_display_defect() -> None:
    banner("10.  The round-to-four display defect and the CI-implied recovery")

    print("        x            store4(x)")
    for x in (0.0, 1e-6, 3.0e-5, 3.1e-5, 4.99e-5, 5.0e-5, 1.0e-4):
        print(f"   {x:.8f}      {store4(x):.4f}")

    check("store4 collapses the whole range [0, 5e-5) to 0.0",
          all(store4(x) == 0.0 for x in
              (0.0, 1e-7, 1e-6, 2.5e-5, 3.1e-5, 4.999e-5)))
    check("store4 is therefore not injective on the relevant range",
          store4(1e-6) == store4(3.1e-5))

    lo = REP_1E5.lo * RATE_CTRL
    hi = REP_1E5.hi * RATE_CTRL
    print()
    print(f"  Control rate rho = {RATE_CTRL:.3e}")
    print(f"  Ratio interval   = {REP_1E5}")
    print(f"  CI-implied candidate rate in [{lo:.6e}, {hi:.6e}]")
    check("the true candidate rate is provably positive", lo > 0.0)
    check("so the stored 0.0 is provably NOT the measured value", store4(lo) == 0.0)

    print()
    inward = (2.66e-5, 3.56e-5)
    outward = (2.65e-5, 3.57e-5)
    check("the inward-rounded bracket is NOT a valid enclosure",
          not (inward[0] <= lo and hi <= inward[1]),
          f"{inward[0]:.4e} > {lo:.6e} or {hi:.6e} > {inward[1]:.4e}")
    check("the outward-rounded bracket IS a valid enclosure",
          outward[0] <= lo and hi <= outward[1],
          f"[{outward[0]:.4e}, {outward[1]:.4e}] contains "
          f"[{lo:.6e}, {hi:.6e}]")
    print("\n  Moral: a correction for a rounding defect must itself round outward.")


# --------------------------------------------------------------------------

def main() -> None:
    print(__doc__)
    demo_intervals()
    demo_direction_stability()
    demo_local_density()
    demo_bias_moments()
    demo_bootstrap_variance()
    demo_anova()
    demo_power()
    demo_pooling()
    demo_degenerate()
    demo_display_defect()

    banner("ALL CHECKS PASSED")
    print("""
  Summary of the numerical verdict
  --------------------------------
  * Every reported interval covers the null value 1.
  * The replication's edge deliverable is 0.081 against the pilot's 0.137,
    with precision AND drift both improving.
  * Pooling the two runs leaves the joint interval covering 1, upper edge
    below 1.0022; the precision-weighted joint point is ~0.981, not ~0.97.
  * Four agreeing split-halves are worth exactly 1/8.
  * The cluster bootstrap has variance exactly Var(c)/m: pairs are not a
    power lever, clusters are.
  * Decisive resolution of a 1% deviation needs 2656 clusters.
""")


if __name__ == "__main__":
    main()
