#!/usr/bin/env python3
"""
Composition, Not Position
=========================

Numerical demonstrations for the exact accounting of a left-edge excess in a
quadratic-residue search window.

Setting
-------
For a modulus N, positions j run over the window

    W(N) = [ isqrt(N) + 1 , 3 * isqrt(N) ]

and the recorded residue is v = j^2 - N.  The "first decile" D1 is the leading
tenth of the window, i.e. the positions with 5*j <= 6*isqrt(N).

The demonstrations below verify, numerically and with exact integer
arithmetic where possible:

  1. the inclusion bound 25*v <= 11*isqrt(N)^2 on the first decile, its
     sharpness, and the resulting bit-length forcing v < 2^95 for N < 2^96;
  2. the exact position/magnitude degeneracy and its inversion
     j = isqrt(N + v);
  3. the closed-form empirical quantile function of the residue on the window,
     and the continuum limit law F(y) = (sqrt(1+y) - 1)/2 with its explicit
     Kolmogorov error bound 1/(2M);
  4. the exact excess decomposition  flat = band + composition, the
     factorisation of the pooled rate ratio, and the Simpson-type
     pure-composition spike in the configuration the geometry forces;
  5. the extremal bounds on the composition factor and the lower bound on the
     composition share of the observed excess;
  6. the pooled-vs-stratified evidence budget, and the truncation-boundary
     gradient produced by a monotone size density;
  7. the multiplicity calibration of the control arm.

Run with:  python3 demo.py
No third-party dependencies.
"""

from __future__ import annotations

import math
from dataclasses import dataclass
from typing import Callable, Iterable, List, Sequence, Tuple

# ---------------------------------------------------------------------------
# Reported empirical inputs (the only numbers taken from the experiment)
# ---------------------------------------------------------------------------

POOLED_HITS: int = 9594
N_MODULI: int = 128
D1_BY_BAND: dict[str, int] = {"<80": 0, "80-89": 85, "90-95": 1469, ">=96": 0}
RR_D1_BY_BAND: dict[str, float] = {"80-89": 1.000, "90-95": 1.097}
FLAT_NULL_EXPECTATION: float = 959.4
FLAT_EXCESS: float = 604.76
BAND_EXCESS: float = 129.66
POOLED_RATE_RATIO: float = 1.637
MATCHED_RATIO: float = 1.097
COMPOSITION_FACTOR: float = 1.4924
DELTA_AICC_POOLED: float = 49.78
DELTA_AICC_STRATA: Tuple[float, float] = (5.94, -0.40)
REGISTERED_BAR: float = 6.0
CONTROL_MAX_ABS_Z: float = 2.53


def rule(title: str) -> None:
    print("\n" + "=" * 74)
    print(title)
    print("=" * 74)


# ---------------------------------------------------------------------------
# 1. Window geometry and the inclusion bound
# ---------------------------------------------------------------------------

def isqrt(n: int) -> int:
    """Exact integer square root (floor)."""
    return math.isqrt(n)


def window(n_mod: int) -> range:
    """The search window [isqrt(N)+1, 3*isqrt(N)] as a range of positions."""
    s = isqrt(n_mod)
    return range(s + 1, 3 * s + 1)


def residue(n_mod: int, j: int) -> int:
    """The recorded residue v = j^2 - N at window position j."""
    return j * j - n_mod


def in_first_decile(n_mod: int, j: int) -> bool:
    """Leading tenth of the window: 10*(j - s) <= 2*s, i.e. 5*j <= 6*s."""
    s = isqrt(n_mod)
    return (s + 1 <= j <= 3 * s) and (5 * j <= 6 * s)


def bitlen(v: int) -> int:
    """Number of binary digits of v (bitlen(0) = 0)."""
    return v.bit_length()


def inclusion_bound_holds(n_mod: int, j: int) -> bool:
    """Certify 25*v <= 11*isqrt(N)^2 for a first-decile position."""
    s = isqrt(n_mod)
    return 25 * residue(n_mod, j) <= 11 * s * s


def edge_fraction_bound_holds(n_mod: int, j: int, p: int, q: int) -> bool:
    """Certify the general bound q^2 v <= (2pq + p^2) s^2 when q*j <= (q+p)*s."""
    s = isqrt(n_mod)
    if q * j > (q + p) * s:
        return True  # hypothesis not met; nothing to certify
    return q * q * residue(n_mod, j) <= (2 * p * q + p * p) * s * s


def demo_inclusion_geometry() -> None:
    rule("1. Inclusion geometry: the first decile is a pure tiny-v stratum")

    # (a) exhaustive certification over a range of moduli
    bad = 0
    checked = 0
    for n_mod in range(2, 4000):
        s = isqrt(n_mod)
        if s == 0:
            continue
        for j in window(n_mod):
            if in_first_decile(n_mod, j):
                checked += 1
                if not inclusion_bound_holds(n_mod, j):
                    bad += 1
                if residue(n_mod, j) <= 0:
                    bad += 1
    print(f"  exhaustive check, N = 2..3999:")
    print(f"    first-decile positions certified : {checked}")
    print(f"    violations of 25v <= 11 s^2      : {bad}")
    print(f"    violations of v > 0              : included above")

    # (b) the general edge-fraction bound at several prefixes
    print("\n  general bound  q^2 v <= (2pq + p^2) s^2  at several prefixes:")
    for (p, q) in [(1, 5), (1, 4), (1, 3), (1, 2), (2, 3)]:
        ok = all(
            edge_fraction_bound_holds(n_mod, j, p, q)
            for n_mod in range(2, 1200)
            for j in window(n_mod)
        )
        print(f"    p/q = {p}/{q}:  constant {2*p*q + p*p:>3} / {q*q:<3}"
              f"   -> v <= {(2*p*q + p*p)/(q*q):.4f} s^2    holds: {ok}")

    # (c) sharpness: N = (5m)^2, j = 6m attains 25v = 11 s^2
    print("\n  sharpness of 11/25 at N = (5m)^2, j = 6m:")
    for m in (1, 7, 100, 10**6):
        n_mod = (5 * m) ** 2
        j = 6 * m
        v = residue(n_mod, j)
        s = isqrt(n_mod)
        print(f"    m = {m:<9} 25v = {25*v:<22} 11 s^2 = {11*s*s:<22}"
              f" equal: {25*v == 11*s*s}")

    # (d) the bit-length forcing, at the actual scale of the experiment
    print("\n  bit-length forcing for 96-bit moduli:")
    limit = 2 ** 96 - 1
    s = isqrt(limit)
    j_last = (6 * s) // 5
    v_last = residue(limit, j_last)
    print(f"    largest N < 2^96, last first-decile position:")
    print(f"      bitlen(v) = {bitlen(v_last)}   (must be < 96):"
          f" {bitlen(v_last) < 96}")
    print(f"      v / 2^95  = {v_last / 2**95:.6f}   (must be < 1)")

    # (e) but deeper in the same window, residues are large
    n_mod = 2 ** 94
    j = 3 * isqrt(n_mod)
    print(f"\n  same window, last position (N = 2^94, j = 3*2^47):")
    print(f"      bitlen(v) = {bitlen(residue(n_mod, j))}  -> the forcing is a"
          f" property of the EDGE, not of the window")

    # (f) the empirical band table is a theorem, not an observation
    print("\n  empirical D1 hit mass by bitlen(v):")
    for band, count in D1_BY_BAND.items():
        note = "  <- forced to 0 by the inclusion bound" if band == ">=96" else ""
        print(f"      {band:>6} : {count:>5}{note}")


# ---------------------------------------------------------------------------
# 2. Position/magnitude degeneracy
# ---------------------------------------------------------------------------

def position_from_residue(n_mod: int, v: int) -> int:
    """Exact inversion of the residue map on the window: j = isqrt(N + v)."""
    return isqrt(n_mod + v)


def demo_degeneracy() -> None:
    rule("2. Position and magnitude are the same statistic at fixed modulus")

    ok_mono = True
    ok_inv = True
    for n_mod in range(2, 3000):
        prev = -1
        for j in window(n_mod):
            v = residue(n_mod, j)
            if v <= prev:
                ok_mono = False
            prev = v
            if position_from_residue(n_mod, v) != j:
                ok_inv = False
    print(f"  residue strictly increasing in position (N = 2..2999): {ok_mono}")
    print(f"  exact inversion  isqrt(N + v) = j                     : {ok_inv}")

    # every positional weight is realised as a magnitude weight
    n_mod = 1_000_003
    w: Callable[[int], float] = lambda j: math.sin(0.001 * j) + 2.0
    m: Callable[[int], float] = lambda v: w(position_from_residue(n_mod, v))
    err = max(abs(w(j) - m(residue(n_mod, j))) for j in window(n_mod))
    print(f"  arbitrary positional weight reproduced by a magnitude weight:")
    print(f"     max |w(j) - m(v(j))| over the whole window = {err:.3e}")

    # only pooling separates them
    print("\n  cross-modulus separation (the sole source of identification):")
    for (n_mod, j) in [(37, 7), (24, 6)]:
        s = isqrt(n_mod)
        print(f"     N = {n_mod:>3}, j = {j}:  v = {residue(n_mod, j):>3},"
              f"  positional rank = {j - s}")
    print("     same residue, different rank -> pooling identifies, and pooling")
    print("     is exactly what imports the band-composition confound.")


# ---------------------------------------------------------------------------
# 3. The quantile identity and the continuum limit law
# ---------------------------------------------------------------------------

def sublevel_count_closed_form(n_mod: int, x: int) -> int:
    """#{ j in W(N) : v <= x } = min(3*isqrt N, isqrt(N+x)) - isqrt N."""
    s = isqrt(n_mod)
    return min(3 * s, isqrt(n_mod + x)) - s


def sublevel_count_bruteforce(n_mod: int, x: int) -> int:
    return sum(1 for j in window(n_mod) if residue(n_mod, j) <= x)


def limit_cdf(y: float) -> float:
    """Limiting c.d.f. of the rescaled residue: (sqrt(1+y) - 1)/2 on [0,8]."""
    return (math.sqrt(1.0 + y) - 1.0) / 2.0


def empirical_fraction(m_root: int, x: int) -> float:
    """Fraction of the 2M window positions of N = M^2 with residue <= x."""
    return sublevel_count_closed_form(m_root * m_root, x) / (2.0 * m_root)


def demo_quantile_law() -> None:
    rule("3. The exact quantile identity and the continuum limit law")

    mismatches = 0
    trials = 0
    for n_mod in range(2, 700):
        s = isqrt(n_mod)
        if s == 0:
            continue
        for x in range(0, 9 * s * s + 1, max(1, (9 * s * s) // 17 + 1)):
            trials += 1
            if sublevel_count_closed_form(n_mod, x) != sublevel_count_bruteforce(n_mod, x):
                mismatches += 1
    print(f"  closed form vs brute force: {trials} thresholds tested,"
          f" {mismatches} mismatches")

    print("\n  Kolmogorov error  |F_M(y M^2) - (sqrt(1+y)-1)/2|  vs the bound 1/(2M):")
    print(f"    {'M':>9} {'y':>6} {'empirical':>12} {'limit':>12} "
          f"{'error':>11} {'1/(2M)':>11}")
    for m_root in (10, 100, 1000, 10000):
        for y in (0.44, 1.0, 4.0, 8.0):
            x = int(y * m_root * m_root)
            f_emp = empirical_fraction(m_root, x)
            f_lim = limit_cdf(x / (m_root * m_root))
            err = abs(f_emp - f_lim)
            print(f"    {m_root:>9} {y:>6.2f} {f_emp:>12.8f} {f_lim:>12.8f} "
                  f"{err:>11.2e} {1/(2*m_root):>11.2e}"
                  f"  {'OK' if err <= 1/(2*m_root) + 1e-12 else 'FAIL'}")

    print("\n  the decile level y = 11/25 is EXACT on the divisible moduli"
          " N = (5m)^2:")
    print(f"    limit value (sqrt(1 + 11/25) - 1)/2 = {limit_cdf(11/25):.12f}")
    for m in (1, 3, 50, 5000):
        n_mod = (5 * m) ** 2
        win = window(n_mod)
        n_win = len(win)
        n_dec = sum(1 for j in win if in_first_decile(n_mod, j))
        n_mag = sum(1 for j in win if residue(n_mod, j) <= 11 * m * m)
        print(f"    m = {m:<6} |W| = {n_win:<8} |D1| = {n_dec:<7}"
              f" |v <= 11m^2| = {n_mag:<7} share = {n_dec/n_win:.12f}")


# ---------------------------------------------------------------------------
# 4. The exact excess decomposition
# ---------------------------------------------------------------------------

@dataclass(frozen=True)
class BandTable:
    """Stratified counts: exposure n_i, observed edge count k_i, band rate p_i."""
    n: Sequence[float]
    k: Sequence[float]
    p: Sequence[float]
    p0: float

    def flat_excess(self) -> float:
        return sum(self.k) - self.p0 * sum(self.n)

    def band_excess(self) -> float:
        return sum(ki - pi * ni for ki, pi, ni in zip(self.k, self.p, self.n))

    def composition(self) -> float:
        return sum((pi - self.p0) * ni for pi, ni in zip(self.p, self.n))

    def composition_factor(self) -> float:
        return sum(pi * ni for pi, ni in zip(self.p, self.n)) / (self.p0 * sum(self.n))

    def pooled_rate_ratio(self) -> float:
        return sum(self.k) / (self.p0 * sum(self.n))


def demo_composition_identity() -> None:
    rule("4. The exact excess decomposition  flat = band + composition")

    # (a) the identity holds with no hypotheses at all
    import random
    random.seed(20260826)
    worst = 0.0
    for _ in range(20000):
        size = random.randint(1, 6)
        tbl = BandTable(
            n=[random.uniform(0, 1000) for _ in range(size)],
            k=[random.uniform(0, 500) for _ in range(size)],
            p=[random.uniform(0, 1) for _ in range(size)],
            p0=random.uniform(0.01, 0.9),
        )
        worst = max(worst, abs(tbl.flat_excess()
                               - (tbl.band_excess() + tbl.composition())))
    print(f"  identity checked on 20000 random band tables;"
          f" worst residual = {worst:.3e}")

    # (b) the pure-composition spike forced by the window geometry
    print("\n  the pure-composition spike (the configuration the geometry forces):")
    spike = BandTable(n=[3000.0, 6594.0], k=[1590.0, 0.0], p=[0.53, 0.0], p0=0.1)
    print(f"    band 0 (tiny v)  : n = {spike.n[0]:>8.0f}  p = {spike.p[0]:.2f}"
          f"  k = {spike.k[0]:>8.0f}   within-band rate ratio = 1.000")
    print(f"    band 1 (large v) : n = {spike.n[1]:>8.0f}  p = {spike.p[1]:.2f}"
          f"  k = {spike.k[1]:>8.0f}   rate mechanically zero")
    print(f"    band-referenced excess : {spike.band_excess():>10.4f}   (exactly 0)")
    print(f"    flat-referenced excess : {spike.flat_excess():>10.4f}")
    print(f"    pooled rate ratio      : {spike.pooled_rate_ratio():>10.4f}")
    print("    -> a spike of >600 with no rate elevation anywhere:"
          " Simpson's paradox.")

    # (c) the two boundary readings
    matched = BandTable(n=[3000.0, 6594.0], k=[1590.0, 0.0], p=[0.53, 0.0], p0=0.1)
    homog = BandTable(n=[3000.0, 6594.0], k=[301.0, 660.0], p=[0.1, 0.1], p0=0.1)
    print("\n  boundary readings:")
    print(f"    size-matched bands  -> flat excess = composition ?"
          f" {abs(matched.flat_excess() - matched.composition()) < 1e-9}")
    print(f"    homogeneous bands   -> composition = 0 ?"
          f" {abs(homog.composition()) < 1e-9}")

    # (d) the reported numbers factorise
    print("\n  factorisation of the reported pooled rate ratio:")
    prod = MATCHED_RATIO * COMPOSITION_FACTOR
    print(f"    matched within-band ratio R      = {MATCHED_RATIO}")
    print(f"    composition factor CF            = {COMPOSITION_FACTOR}")
    print(f"    R * CF                           = {prod:.6f}")
    print(f"    observed pooled rate ratio       = {POOLED_RATE_RATIO}")
    print(f"    |R*CF - observed|                = {abs(prod - POOLED_RATE_RATIO):.6f}"
          f"   (<= 0.0002: {abs(prod - POOLED_RATE_RATIO) <= 0.0002})")
    print("    -> nothing left over for a positional component.")


# ---------------------------------------------------------------------------
# 5. Extremal composition and the composition share
# ---------------------------------------------------------------------------

def composition_share_lower_bound(flat_excess: float, matched_ratio: float,
                                  flat_expectation: float) -> float:
    """(flat excess - (R-1)*E)/R : the guaranteed composition mass."""
    return (flat_excess - (matched_ratio - 1.0) * flat_expectation) / matched_ratio


def demo_extremal_and_share() -> None:
    rule("5. Extremal composition and the guaranteed composition share")

    import random
    random.seed(11)
    p0, pmin, pmax = 0.1, 0.0, 0.14924
    lo, hi = math.inf, -math.inf
    for _ in range(200000):
        size = random.randint(1, 5)
        p = [random.uniform(pmin, pmax) for _ in range(size)]
        n = [random.uniform(0, 5000) for _ in range(size)]
        cf = sum(pi * ni for pi, ni in zip(p, n)) / (p0 * sum(n))
        lo, hi = min(lo, cf), max(hi, cf)
    print(f"  composition factor over 200000 random allocations:")
    print(f"    observed range  [{lo:.6f}, {hi:.6f}]")
    print(f"    proved range    [{pmin/p0:.6f}, {pmax/p0:.6f}]"
          f"   contained: {lo >= pmin/p0 - 1e-9 and hi <= pmax/p0 + 1e-9}")
    print("    -> bounded by the RATE SPREAD, never by the sample size.")

    print("\n  universal ceiling on the pooled rate ratio:")
    print(f"    R <= {MATCHED_RATIO}, pmax/p0 <= {pmax/p0:.4f}"
          f"  =>  pooled <= {MATCHED_RATIO * pmax / p0:.4f}  (<= 1.638)")
    print(f"    observed pooled ratio {POOLED_RATE_RATIO} sits inside the ceiling.")

    print("\n  guaranteed composition share of the observed excess:")
    bound = composition_share_lower_bound(FLAT_EXCESS, MATCHED_RATIO,
                                          FLAT_NULL_EXPECTATION)
    print(f"    flat excess          = {FLAT_EXCESS}")
    print(f"    flat-null expectation = {FLAT_NULL_EXPECTATION}")
    print(f"    matched ratio R      = {MATCHED_RATIO}")
    print(f"    composition >= (flat - (R-1)E)/R = {bound:.4f}")
    print(f"    share                = {bound / FLAT_EXCESS * 100:.2f} %"
          f"   (>= 77 %: {bound / FLAT_EXCESS >= 0.77})")
    print(f"    reported band-referenced excess = {BAND_EXCESS}"
          f"  (the residual rate part)")


# ---------------------------------------------------------------------------
# 6. Evidence budget and the truncation-boundary gradient
# ---------------------------------------------------------------------------

def aicc_penalty(k: float, n: float) -> float:
    """2k + 2k(k+1)/(n - k - 1)."""
    return 2.0 * k + 2.0 * k * (k + 1.0) / (n - k - 1.0)


def implied_null_gap(delta_pooled: float, strata: Iterable[float],
                     penalty_defect: float) -> float:
    """Solve  pooled <= sum(strata) + G + defect  for the minimal G."""
    return delta_pooled - sum(strata) - penalty_defect


def edge_excess(f: Callable[[int], float], m: int) -> float:
    """Lower-half mass minus upper-half mass over a band of 2m size cells."""
    lower = sum(f(i) for i in range(m))
    upper = sum(f(i) for i in range(m, 2 * m))
    return lower - upper


def relative_edge(r: float, m: int) -> float:
    """Relative edge excess of the geometric density f(i) = r^i."""
    return (1.0 - r ** m) / (1.0 + r ** m)


def demo_evidence_and_gradient() -> None:
    rule("6. Evidence budget and the truncation-boundary gradient")

    gap = implied_null_gap(DELTA_AICC_POOLED, DELTA_AICC_STRATA, 3.0)
    print(f"  pooled dAICc              = {DELTA_AICC_POOLED}")
    print(f"  stratified dAICc          = {DELTA_AICC_STRATA[0]} (bitlen [96,98)),"
          f" {DELTA_AICC_STRATA[1]} (bitlen >= 98)")
    print(f"  registered decision bar   = {REGISTERED_BAR}"
          f"   -> both strata sub-bar: "
          f"{all(d <= REGISTERED_BAR for d in DELTA_AICC_STRATA)}")
    print(f"  penalty defect assumed    <= 3")
    print(f"  implied null gap G        >= {gap:.2f}")
    print(f"  share of pooled statistic that is null heterogeneity:"
          f" {gap / DELTA_AICC_POOLED * 100:.1f} %")

    print("\n  stratification is the conservative analysis"
          " (penalty decreases in sample size):")
    for n in (100, 500, 2000, 9594):
        print(f"    pen(k=3, n={n:<5}) = {aicc_penalty(3.0, float(n)):.6f}")

    print("\n  a monotone size density manufactures an edge component:")
    print(f"    {'density':>26} {'m':>4} {'edge excess':>14} {'relative':>11}")
    for name, f, note in [
        ("flat  f(i) = 1", lambda i: 1.0, "exactly zero"),
        ("steep f(i) = 0.70^i", lambda i: 0.70 ** i, "truncation boundary"),
        ("mild  f(i) = 0.95^i", lambda i: 0.95 ** i, "two bands out"),
        ("flat  f(i) = 0.999^i", lambda i: 0.999 ** i, "far from the cut"),
    ]:
        m = 8
        ee = edge_excess(f, m)
        tot = sum(f(i) for i in range(2 * m))
        print(f"    {name:>26} {m:>4} {ee:>14.6f} {ee/tot:>11.6f}   {note}")

    print("\n  exact relative edge excess of a geometric density, and its bound:")
    print(f"    {'r':>8} {'m':>4} {'(1-r^m)/(1+r^m)':>18} {'m(1-r)':>12}")
    for r in (0.70, 0.90, 0.95, 0.99, 0.999):
        m = 8
        print(f"    {r:>8.3f} {m:>4} {relative_edge(r, m):>18.8f}"
              f" {m*(1-r):>12.8f}"
              f"   {'OK' if relative_edge(r, m) <= m*(1-r) + 1e-12 else 'FAIL'}")
    print("    -> steep near the cut, vanishing away from it:"
          " the observed [96,98) / >=98 pattern.")


# ---------------------------------------------------------------------------
# 7. Control-arm multiplicity calibration
# ---------------------------------------------------------------------------

def bonferroni_subgaussian_bound(m: int, t: float) -> float:
    """2 m exp(-t^2/2): the multiplicity-corrected sub-Gaussian tail bound."""
    return 2.0 * m * math.exp(-t * t / 2.0)


def bonferroni_threshold(m: int, alpha: float) -> float:
    """Smallest t with 2 m exp(-t^2/2) <= alpha."""
    return math.sqrt(2.0 * math.log(2.0 * m / alpha))


def demo_controls() -> None:
    rule("7. What a maximal control |z| of 2.53 over 128 strata can say")

    bound = bonferroni_subgaussian_bound(N_MODULI, CONTROL_MAX_ABS_Z)
    print(f"  controls: {N_MODULI} strata, max |z| = {CONTROL_MAX_ABS_Z}")
    print(f"  multiplicity-corrected bound 2m exp(-t^2/2) = {bound:.4f}")
    print(f"  bound exceeds 1 (i.e. is vacuous): {bound > 1.0}")
    t5 = bonferroni_threshold(N_MODULI, 0.05)
    print(f"  threshold clearing a 5% Bonferroni bar over {N_MODULI} strata:"
          f" t = {t5:.4f}  (> 4: {t5 > 4})")
    print(f"  observed max |z| = {CONTROL_MAX_ABS_Z} is far below it.")
    print("  -> 'controls clean' means NO EXCEEDANCE WAS PRODUCED;")
    print("     it is not evidence FOR the null.")


# ---------------------------------------------------------------------------
# 8. Verdict
# ---------------------------------------------------------------------------

def demo_verdict() -> None:
    rule("8. The verdict, assembled")
    print("  1. mechanical exclusion : every first-decile hit has bitlen(v) < 96")
    print("                            (exact arithmetic, scale-carrying)")
    print("  2. composition          : 1.097 x 1.4924 = "
          f"{MATCHED_RATIO*COMPOSITION_FACTOR:.4f} reproduces the")
    print(f"                            observed pooled ratio {POOLED_RATE_RATIO};"
          " >= 77 % of the")
    print("                            excess is provably composition")
    print("  3. evidence             : the pooled dAICc 49.78 needs a null gap")
    print(f"                            G >= "
          f"{implied_null_gap(DELTA_AICC_POOLED, DELTA_AICC_STRATA, 3.0):.2f};"
          " both matched strata")
    print("                            are sub-bar, and the residual sits at the")
    print("                            truncation boundary only")
    print("\n  => NO POSITIONAL KERNEL COMPONENT SURVIVES.")
    print("     The overdispersion (+605 hits) is real and now has a named origin:")
    print("     magnitude composition forced by the window's geometry.")


def main() -> None:
    print(__doc__.split("Run with:")[0].strip())
    demo_inclusion_geometry()
    demo_degeneracy()
    demo_quantile_law()
    demo_composition_identity()
    demo_extremal_and_share()
    demo_evidence_and_gradient()
    demo_controls()
    demo_verdict()


if __name__ == "__main__":
    main()
