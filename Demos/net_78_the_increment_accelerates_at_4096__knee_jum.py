"""
Attention key-budget laws: numerical demonstration of every result.

Self-contained (standard library only).  Run with:  python3 demo.py

Setting
-------
Index context doublings above a base context of 512 tokens by j, so the context
length is N_j = 512 * 2**j.  For a half-billion-parameter model the measured
"knee" -- the smallest number of cached keys whose retained attention mass meets
a fixed gate -- is

        j     :   0     1     2     3
        N_j   : 512  1024  2048  4096
        k*    :  16    20    24    40      (increments +4, +4, +16)

This script verifies, numerically, every claim of the accompanying paper.
"""

from __future__ import annotations

from math import comb, exp, log
from typing import Callable, Dict, List, Sequence, Tuple

BASE_CTX: int = 512
CHAIN: Tuple[int, int, int, int] = (16, 20, 24, 40)

# The retention table measured at ctx = 4096 over the trial grid.
GRID: Tuple[int, ...] = (16, 20, 24, 28, 32, 40)
RETENTION: Tuple[float, ...] = (0.959, 0.969, 0.975, 0.977, 0.979, 0.984)


# ----------------------------------------------------------------------------
# 0.  Basic objects
# ----------------------------------------------------------------------------

def context_length(j: int) -> int:
    """Context length after j doublings above the base context."""
    return BASE_CTX * 2 ** j


def pos(x: int) -> int:
    """Truncated (positive-part) subtraction helper: (x)_+ ."""
    return x if x > 0 else 0


def knee_ramp(j: int) -> int:
    """Ramp fit: linear with a single kink at the second doubling."""
    return 16 + 4 * j + 12 * pos(j - 2)


def knee_cubic(j: int) -> int:
    """Cubic Newton interpolant through the four measured knees."""
    return 16 + 4 * j + 12 * comb(j, 3)


def knee_geometric(j: int) -> int:
    """Geometric fit: the increment itself multiplies by 4 past the corner."""
    return 16 + 4 * j + 4 * (4 ** pos(j - 2) - 1)


def fits_chain(f: Callable[[int], int]) -> bool:
    """Does the budget law reproduce 16, 20, 24, 40 at j = 0, 1, 2, 3?"""
    return tuple(f(j) for j in range(4)) == CHAIN


def is_convex(f: Callable[[int], int], upto: int = 30) -> bool:
    """Discrete convexity: per-doubling increments never decrease."""
    return all(2 * f(j + 1) <= f(j) + f(j + 2) for j in range(upto))


def is_feasible(f: Callable[[int], int], upto: int = 30) -> bool:
    """A cache can never hold more keys than the context has tokens."""
    return all(f(j) <= context_length(j) for j in range(upto))


# ----------------------------------------------------------------------------
# 1.  Refutation and underdetermination
# ----------------------------------------------------------------------------

def no_affine_law_fits() -> bool:
    """Exhaustive check that no law k0 + d*j reproduces the chain."""
    for k0 in range(0, 200):
        for d in range(0, 200):
            if tuple(k0 + d * j for j in range(4)) == CHAIN:
                return False
    return True


def demo_underdetermination() -> None:
    print("=" * 74)
    print("1.  REFUTATION AND UNDERDETERMINATION")
    print("=" * 74)
    print(f"  measured chain           : {CHAIN}  (increments +4, +4, +16)")
    print(f"  extrapolated 16 + 4j     : {tuple(16 + 4 * j for j in range(4))}"
          "   <- predicts 28, refuted")
    print(f"  no affine law fits       : {no_affine_law_fits()}")
    print()
    laws: Dict[str, Callable[[int], int]] = {
        "ramp        ": knee_ramp,
        "cubic       ": knee_cubic,
        "geometric   ": knee_geometric,
    }
    print("  law            j=0  1   2   3  |  j=4 (ctx 8192)   fits?")
    for name, f in laws.items():
        vals = [f(j) for j in range(4)]
        print(f"  {name}  {vals[0]:3d} {vals[1]:3d} {vals[2]:3d} {vals[3]:3d}"
              f"  |  {f(4):5d}            {fits_chain(f)}")
    print("  -> three laws, one data set, predictions 56 / 80 / 92 at 8192.")
    print()


# ----------------------------------------------------------------------------
# 2.  What convexity forces
# ----------------------------------------------------------------------------

def convex_floor(m: int) -> int:
    """Forced lower bound f(m+3) >= 40 + 16m for every convex fit."""
    return 40 + 16 * m


def demo_convexity() -> None:
    print("=" * 74)
    print("2.  WHAT CONVEXITY FORCES")
    print("=" * 74)
    print("  m   ctx        floor 40+16m   ramp     cubic    ceiling 512*2^j")
    for m in range(0, 7):
        j = m + 3
        print(f"  {m}   {context_length(j):9d}  {convex_floor(m):9d}"
              f"    {knee_ramp(j):7d}  {knee_cubic(j):7d}  {context_length(j):12d}")
    print("  -> the ramp attains the floor exactly; the band is inhabited.")
    print(f"  convexity of ramp / cubic / geometric: "
          f"{is_convex(knee_ramp)} / {is_convex(knee_cubic)} / {is_convex(knee_geometric)}")
    budget = 1000
    j_break = next(j for j in range(1000) if knee_ramp(j) > budget)
    print(f"  no uniform budget: a {budget}-key cache already fails at j = {j_break} "
          f"(ctx = {context_length(j_break)}).")
    print()


# ----------------------------------------------------------------------------
# 3.  The tropical corner and the tangent envelope
# ----------------------------------------------------------------------------

def tropical_two_term(j: int) -> int:
    """The ramp fit as a two-monomial max-plus polynomial."""
    return max(16 + 4 * j, 16 * j - 8)


def tangent(f: Callable[[int], int], i: int, j: int) -> int:
    """Tangent of f at i, evaluated at j >= i."""
    return f(i) + pos(j - i) * (f(i + 1) - f(i))


def tropical_envelope(f: Callable[[int], int], J: int) -> int:
    """max_{i <= J} tangent(f, i, J):  a convex law is its own envelope."""
    return max(tangent(f, i, J) for i in range(J + 1))


def active_monomials(f: Callable[[int], int], J: int) -> List[int]:
    """Indices i whose tangent attains the envelope at J."""
    best = tropical_envelope(f, J)
    return [i for i in range(J + 1) if tangent(f, i, J) == best]


def demo_tropical() -> None:
    print("=" * 74)
    print("3.  THE TRANSITION IS A TROPICAL CORNER")
    print("=" * 74)
    ok = all(knee_ramp(j) == tropical_two_term(j) for j in range(40))
    print(f"  ramp(j) == max(16 + 4j, 16j - 8) for all j < 40 : {ok}")
    x_star = (16 + 8) / (16 - 4)
    print(f"  the two monomials cross at x = {x_star:.4f}  ->  ctx = "
          f"{context_length(int(x_star))} tokens   (the corner)")
    print()
    print("  discrete Legendre biconjugation:  f(J) == max_{i<=J} T_i(J)")
    print("   J    f(J)   envelope   active tangents")
    for J in range(0, 8):
        print(f"  {J:2d}  {knee_ramp(J):6d}   {tropical_envelope(knee_ramp, J):8d}"
              f"   {active_monomials(knee_ramp, J)}")
    print("  -> past the corner only the tangents at j = 0 (slope 4) and")
    print("     j = 2 (slope 16) survive; they meet at j = 2, i.e. ctx = 2048.")
    print()


# ----------------------------------------------------------------------------
# 4.  Grid-honest inference: gate, bracket, sharpness
# ----------------------------------------------------------------------------

def retention(profile: Dict[int, float], k: int) -> float:
    """Mass carried by the k largest keys: sum of p_i over i < k."""
    return sum(v for i, v in profile.items() if i < k)


def knee(profile: Dict[int, float], tau: float, kmax: int = 4096) -> int:
    """Smallest budget whose retention meets the gate."""
    return next(k for k in range(kmax + 1) if retention(profile, k) >= tau - 1e-12)


P_LOW: Dict[int, float] = {0: 0.959, 16: 0.010, 20: 0.006,
                           24: 0.002, 28: 0.002, 32: 0.005}
P_HIGH: Dict[int, float] = {0: 0.959, 16: 0.010, 20: 0.006,
                            24: 0.002, 28: 0.002, 39: 0.005}


def matches_table(profile: Dict[int, float]) -> bool:
    return all(abs(retention(profile, g) - r) < 1e-9
               for g, r in zip(GRID, RETENTION))


def gate_bracket() -> Tuple[float, float]:
    """(lower, upper] gate range implied by the knee being read as 40."""
    return RETENTION[-2], RETENTION[-1]


def knee_bracket() -> Tuple[int, int]:
    """Certified bracket for the true (off-grid) knee."""
    return GRID[-2] + 1, GRID[-1]


def demo_grid() -> None:
    print("=" * 74)
    print("4.  GRID-HONEST INFERENCE")
    print("=" * 74)
    print("   k   :" + "".join(f"{g:8d}" for g in GRID))
    print("   R(k):" + "".join(f"{r:8.3f}" for r in RETENTION))
    lo, hi = gate_bracket()
    print(f"  gate recovered from the table : {lo} < tau <= {hi}")
    klo, khi = knee_bracket()
    print(f"  certified knee bracket        : [{klo}, {khi}]")
    print()
    tau = 0.98
    print(f"  two profiles matching the WHOLE table, at gate tau = {tau}:")
    print(f"    p_low  matches table = {matches_table(P_LOW)},  true knee = "
          f"{knee(P_LOW, tau)}")
    print(f"    p_high matches table = {matches_table(P_HIGH)},  true knee = "
          f"{knee(P_HIGH, tau)}")
    print("  -> the bracket [33, 40] is sharp: same data, knees 7 apart.")
    print()
    inc_lo, inc_hi = klo - 24, khi - 24
    print(f"  honest acceleration: increment in [{inc_lo}, {inc_hi}], factor in "
          f"[{inc_lo / 4:.2f}, {inc_hi / 4:.2f}]")
    print("  (the advertised 4x is the TOP of a bracket whose bottom is 2.25)")
    print()
    print("  deployment trichotomy at ctx = 4096:")
    for B in (16, 24, 32, 33, 36, 39, 40, 64):
        if B <= 32:
            verdict = "PROVABLY UNSAFE"
        elif B >= 40:
            verdict = "CERTIFIED SAFE"
        else:
            verdict = (f"UNDECIDED  (p_low passes: "
                       f"{retention(P_LOW, B) >= tau}, p_high passes: "
                       f"{retention(P_HIGH, B) >= tau})")
        print(f"    budget {B:3d} keys : {verdict}")
    print("  -> a 24-key cache, correct at ctx = 2048, FAILS at ctx = 4096.")
    print()


# ----------------------------------------------------------------------------
# 5.  The continuous layer: rates and reciprocity
# ----------------------------------------------------------------------------

def knee_cts(lam: float, delta: float) -> float:
    """Continuous knee of an exponential tail: log(1/delta) / lambda."""
    return log(1.0 / delta) / lam


def lam_crossover(lam0: float, j: int) -> float:
    """Crossover rate family: inverse rate gains an extra slope past j = 2."""
    return lam0 / (4.0 + j + 3.0 * max(j - 2.0, 0.0))


def demo_rates() -> None:
    print("=" * 74)
    print("5.  THE CONTINUOUS LAYER: RATES AND RECIPROCITY")
    print("=" * 74)
    delta = exp(-4.0)
    print(f"  tail budget delta = e^-4, base rate lam0 = 1")
    print("   j   lambda_j    knee = log(1/delta)/lambda_j   ramp(j)")
    for j in range(4):
        lam = lam_crossover(1.0, j)
        print(f"  {j:2d}   {lam:8.5f}    {knee_cts(lam, delta):20.4f}"
              f"   {knee_ramp(j):7d}")
    lams = [lam_crossover(1.0, j) for j in range(4)]
    r23 = lams[2] / lams[1]
    r34 = lams[3] / lams[2]
    print(f"  rate ratios: lam2/lam1 = {r23:.4f} (= 5/6), "
          f"lam3/lam2 = {r34:.4f} (= 3/5)")
    print(f"  relative collapse accelerates: {r34:.4f} < {r23:.4f} -> "
          f"{r34 < r23}")
    print()
    print("  robustness to the grid gap (knee at 4096 anywhere in [33, 40]):")
    for k3 in range(33, 41):
        # lam_j = log(1/delta)/k_j, so lam3/lam2 = k2/k3 = 24/k3.
        print(f"    true knee {k3}:  lam3/lam2 = {24 / k3:.4f} < "
              f"{20 / 24:.4f} = lam2/lam1 -> {24 / k3 < 20 / 24}")
    print("  -> the phase transition survives the grid gap; only its size does not.")
    print()
    print("  refuted family lam_j = lam0/(j+1) gives an AFFINE knee:")
    print("   ", [round(knee_cts(1.0 / (j + 1), delta), 2) for j in range(4)],
          " (constant increment 4 -- cannot reach 40)")
    print()


# ----------------------------------------------------------------------------
# 6.  Feasibility and compression
# ----------------------------------------------------------------------------

def first_infeasible(f: Callable[[int], int], upto: int = 40) -> int:
    """First doubling index at which a law demands more keys than tokens."""
    for j in range(upto):
        if f(j) > context_length(j):
            return j
    return -1


def keep_fraction(f: Callable[[int], int], j: int) -> float:
    """Fraction of the context retained by the law."""
    return f(j) / context_length(j)


def demo_feasibility() -> None:
    print("=" * 74)
    print("6.  FEASIBILITY AND COMPRESSION")
    print("=" * 74)
    for name, f in (("ramp", knee_ramp), ("cubic", knee_cubic),
                    ("geometric", knee_geometric)):
        j_bad = first_infeasible(f)
        status = "FEASIBLE" if j_bad < 0 else f"INFEASIBLE from j = {j_bad}"
        print(f"  {name:10s}: {status}")
    j_bad = first_infeasible(knee_geometric)
    print(f"  at j = {j_bad}: the geometric law demands "
          f"{knee_geometric(j_bad):,} keys for a "
          f"{context_length(j_bad):,}-token context.")
    print("  -> one of the three continuations dies with no new data;")
    print("     the survivors differ by 56 vs 80 keys at ctx = 8192.")
    print()
    print("  keep fraction f(j) / (512 * 2^j):")
    print("     j      ctx           ramp          cubic")
    for j in (0, 3, 5, 10, 20, 30):
        print(f"  {j:4d}  {context_length(j):13,d}  "
              f"{keep_fraction(knee_ramp, j):12.3e}  "
              f"{keep_fraction(knee_cubic, j):12.3e}")
    print("  -> both surviving laws retain a vanishing fraction: the transition")
    print("     changes the constant, not the compressibility.")
    print()


# ----------------------------------------------------------------------------
# 7.  The discriminating transfer experiment
# ----------------------------------------------------------------------------

def knee_small(j: int) -> int:
    """Pre-transition law of the 0.5B model."""
    return 16 + 4 * j


def knee_large(j: int) -> int:
    """Measured law of the threefold larger model: 16, 16, 18, 20, ..."""
    return 16 + 2 * pos(j - 1)


def crossing_index(f: Callable[[int], int], K: int, upto: int = 100) -> int:
    """First doubling at which the law demands at least K keys."""
    return next(j for j in range(upto) if f(j) >= K)


def knee_large_ctx(j: int) -> int:
    """CTX hypothesis: the corner is a critical context length (j = 2)."""
    return knee_large(j) + 8 * pos(j - 2)


def knee_large_bud(j: int) -> int:
    """BUD hypothesis: the corner is a critical key budget (24 keys)."""
    return knee_large(j) + 8 * pos(j - crossing_index(knee_large, 24))


def demo_transfer() -> None:
    print("=" * 74)
    print("7.  THE DISCRIMINATING TRANSFER EXPERIMENT")
    print("=" * 74)
    j_small = crossing_index(knee_small, 24)
    j_large = crossing_index(knee_large, 24)
    print(f"  0.5B law 16+4j crosses 24 keys at j = {j_small} "
          f"(ctx = {context_length(j_small)})  <- the OBSERVED corner")
    print(f"  1.5B law crosses 24 keys at j = {j_large} "
          f"(ctx = {context_length(j_large)})  <- an eightfold delay")
    print()
    print("   j    ctx      CTX prediction   BUD prediction")
    for j in range(5):
        mark = "   <- measured" if j <= 2 else ""
        print(f"  {j:2d}  {context_length(j):6d}   {knee_large_ctx(j):12d}"
              f"   {knee_large_bud(j):14d}{mark}")
    print(f"  agree on all measured points; differ by "
          f"{knee_large_ctx(3) - knee_large_bud(3)} keys at ctx = 4096.")
    print(f"  both convex : {is_convex(knee_large_ctx)} / {is_convex(knee_large_bud)}"
          f"   both feasible : {is_feasible(knee_large_ctx)} / "
          f"{is_feasible(knee_large_bud)}")
    print(f"  scale advantage survives: {knee_large_ctx(3)} < 40 and "
          f"{knee_large_bud(3)} < 40.")
    print()


# ----------------------------------------------------------------------------

def main() -> None:
    print()
    print("ATTENTION KEY-BUDGET LAWS -- NUMERICAL DEMONSTRATION")
    print()
    demo_underdetermination()
    demo_convexity()
    demo_tropical()
    demo_grid()
    demo_rates()
    demo_feasibility()
    demo_transfer()
    print("=" * 74)
    print("SUMMARY")
    print("=" * 74)
    print("  * No affine law fits 16, 20, 24, 40 -- the linear increment breaks.")
    print("  * Three fits agree on the data and predict 56 / 80 / 92 at 8192.")
    print("  * Every convex fit needs at least 40 + 16m keys m octaves later.")
    print("  * The minimal fit is max(16+4j, 16j-8); its tropical corner is at")
    print("    ctx = 2048, and every monotone convex law is the max-plus")
    print("    polynomial of its own tangents.")
    print("  * The coarse grid brackets the true knee in [33, 40]; the honest")
    print("    acceleration factor is in [2.25, 4], not exactly 4.")
    print("  * A 24-key cache fails at ctx = 4096 for every consistent profile.")
    print("  * Feasibility kills the compounding continuation for free.")
    print("  * One cell of the larger model at 4096 (28 vs 20) decides whether")
    print("    the corner belongs to the context or to the budget.")
    print()


if __name__ == "__main__":
    main()
