#!/usr/bin/env python3
"""
Internalization Saturates at Two
================================

Numerical demonstration of the convexity theory of exclusive-channel ablations.

Setting
-------
A trained sequential cell owns `k` *exclusive* coordinates -- hidden-state
coordinates that only the end-of-sequence (boundary) pathway writes into.  At
inference time the stored coefficient vector `c` on those coordinates is edited
and the model is re-evaluated.  Five interventions:

    ctl          c
    zeroAll      0
    zeroAt(i)    c with entry i set to 0
    flipAt(i)    c with entry i negated
    scaleAll(l)  l * c

The paradigmatic measured arm (k = 2) is

    ctl 0.9980 | zeroAt0 0.9961 | zeroAt1 0.9990
    zeroAll 0.7544 | flipAt0 0.7505 | scale(0.1) 0.9067

i.e. each coordinate is individually dispensable, the block is indispensable,
and a sign flip is as damaging as deleting the block.

This script demonstrates, in order:

  1. The k = 1 collapse: zeroAt(0) and zeroAll are literally the same map.
  2. The affine intervention algebra and its two-sided no-go.
  3. The convexity dichotomy and the redundancy defect R = sum(d_i) - D.
  4. The 1/k saturation law under concavity.
  5. An explicit item population reproducing all six measured accuracies.
  6. The derived design rule: >= 2 dims for self-sufficiency, >= 3 for sign
     robustness.
  7. Why the k = 1 rows constrain nothing.

Run:  python3 demo.py
"""

from __future__ import annotations

import math
from dataclasses import dataclass
from typing import Callable, Dict, List, Sequence, Tuple

# ---------------------------------------------------------------------------
# 0. Measured data (the published arm and the width ladder)
# ---------------------------------------------------------------------------

MEASURED_S13_K2: Dict[str, float] = {
    "ctl": 0.9980,
    "zeroAt0": 0.9961,
    "zeroAt1": 0.9990,
    "zeroAll": 0.7544,
    "flipAt0": 0.7505,
    "scale0.1": 0.9067,
}

NOOP_BAND: float = 0.002       # reported single-coordinate no-op tolerance
MODEL_TOLERANCE: float = 0.005  # reported no-op scale for model/measurement match


def banner(title: str) -> None:
    print()
    print("=" * 78)
    print(title)
    print("=" * 78)


# ---------------------------------------------------------------------------
# 1. The interventions, and the k = 1 collapse
# ---------------------------------------------------------------------------

def zero_at(c: Sequence[float], i: int) -> List[float]:
    """Set exclusive coordinate `i` to zero."""
    out = list(c)
    out[i] = 0.0
    return out


def zero_all(c: Sequence[float]) -> List[float]:
    """Freeze the whole exclusive block."""
    return [0.0] * len(c)


def flip_at(c: Sequence[float], i: int) -> List[float]:
    """Negate exclusive coordinate `i`."""
    out = list(c)
    out[i] = -out[i]
    return out


def scale_all(c: Sequence[float], lam: float) -> List[float]:
    """Rescale the whole exclusive block by `lam`."""
    return [lam * x for x in c]


def demo_missing_middle() -> None:
    """The counting theorem: the signature forces k >= 2, for ANY statistic."""
    banner("1.  THE MISSING MIDDLE  --  a counting theorem")

    print("At k = 1 the single-coordinate ablation IS the whole-block ablation:")
    for c in ([0.701], [-1.25], [3.0]):
        same = zero_at(c, 0) == zero_all(c)
        print(f"    c = {c!s:>10}   zeroAt(0) = {zero_at(c,0)!s:>7}"
              f"   zeroAll = {zero_all(c)!s:>7}   identical: {same}")

    print("\nHence no statistic F whatsoever can have")
    print("    F(zeroAt_i(c)) == F(c) for all i     and     F(zeroAll(c)) != F(c)")
    print("unless k >= 2.  The phenomenon is invisible at unit width for")
    print("STRUCTURAL, not empirical, reasons.\n")

    print("At k = 2 the two maps genuinely differ:")
    c2 = [0.701, 0.660]
    print(f"    c = {c2}   zeroAt(0) = {zero_at(c2,0)}   zeroAll = {zero_all(c2)}")


# ---------------------------------------------------------------------------
# 2. The affine intervention algebra and the no-go
# ---------------------------------------------------------------------------

def affine_margin(b: float, g: Sequence[float], c: Sequence[float]) -> float:
    """Affine boundary margin  M(c) = b + sum_i g_i c_i."""
    return b + sum(gi * ci for gi, ci in zip(g, c))


def affine_drops(b: float, g: Sequence[float], c: Sequence[float]
                 ) -> Tuple[List[float], float, List[float]]:
    """Return (single-ablation drops, block drop, flip drops) for an affine read-out."""
    m = affine_margin(b, g, c)
    singles = [m - affine_margin(b, g, zero_at(c, i)) for i in range(len(c))]
    block = m - affine_margin(b, g, zero_all(c))
    flips = [m - affine_margin(b, g, flip_at(c, i)) for i in range(len(c))]
    return singles, block, flips


def min_affine_width(block_drop: float, eps: float) -> int:
    """Smallest width compatible with an affine (or convex) read-out."""
    return math.ceil(block_drop / eps)


def demo_affine_nogo() -> None:
    banner("2.  THE AFFINE ALGEBRA, AND ITS TWO-SIDED NO-GO")

    b, g, c = 0.30, [0.25, -0.40], [1.7, 0.9]
    singles, block, flips = affine_drops(b, g, c)
    print("Affine read-out  M(c) = b + sum g_i c_i   with")
    print(f"    b = {b},  g = {g},  c = {c}\n")
    print(f"    single drops d_i        = {[round(x, 6) for x in singles]}")
    print(f"    sum of single drops     = {sum(singles):.6f}")
    print(f"    block drop D            = {block:.6f}")
    print(f"    ADDITIVITY holds        : {abs(sum(singles) - block) < 1e-12}")
    print(f"    flip drops              = {[round(x, 6) for x in flips]}")
    print(f"    FLIP = 2 x ABLATION     : "
          f"{all(abs(f - 2*d) < 1e-12 for f, d in zip(flips, singles))}")
    for lam in (0.0, 0.1, 0.5, 1.0):
        drop = affine_margin(b, g, c) - affine_margin(b, g, scale_all(c, lam))
        print(f"    scale({lam:>3}) drop        = {drop:+.6f}"
              f"   predicted (1-l)D = {(1-lam)*block:+.6f}")

    print("\nNow feed in the measurement.")
    d_meas = [MEASURED_S13_K2["ctl"] - MEASURED_S13_K2["zeroAt0"],
              MEASURED_S13_K2["ctl"] - MEASURED_S13_K2["zeroAt1"]]
    D_meas = MEASURED_S13_K2["ctl"] - MEASURED_S13_K2["zeroAll"]
    F_meas = MEASURED_S13_K2["ctl"] - MEASURED_S13_K2["flipAt0"]
    print(f"    measured single drops   = {[round(x, 4) for x in d_meas]}"
          f"   (both inside +/-{NOOP_BAND})")
    print(f"    measured block drop D   = {D_meas:.4f}")
    print(f"    measured flip drop      = {F_meas:.4f}")
    print(f"\n  ABLATION NO-GO: additivity caps D at k*eps = "
          f"2 x {NOOP_BAND} = {2*NOOP_BAND:.4f}, "
          f"but D = {D_meas:.4f}  ->  IMPOSSIBLE")
    print(f"  An affine read-out would need at least "
          f"{min_affine_width(D_meas, NOOP_BAND)} exclusive dimensions.")
    print(f"\n  SIGN NO-GO (width-free): flip = 2 x ablation forces "
          f"|d| = {F_meas/2:.5f} > {NOOP_BAND}  ->  IMPOSSIBLE AT EVERY k")


# ---------------------------------------------------------------------------
# 3. The convexity dichotomy and the redundancy defect
# ---------------------------------------------------------------------------

def block_and_single_drops(phi: Callable[[float], float], s: Sequence[float]
                           ) -> Tuple[float, List[float]]:
    """Return (D, [d_i]) for read-out phi along the block ray with gains s."""
    S = sum(s)
    D = phi(S) - phi(0.0)
    d = [phi(S) - phi(S - si) for si in s]
    return D, d


def redundancy_defect(phi: Callable[[float], float], s: Sequence[float]) -> float:
    """R = sum_i d_i - D.  R >= 0 convex, = 0 affine, <= 0 concave."""
    D, d = block_and_single_drops(phi, s)
    return sum(d) - D


def curvature_verdict(R: float, tau: float = 1e-9) -> str:
    if R > tau:
        return "convex-compatible only (R > 0)"
    if R < -tau:
        return "STRICTLY CONCAVE / saturating (R < 0)"
    return "affine-compatible (R = 0)"


def demo_convexity_dichotomy() -> None:
    banner("3.  THE CONVEXITY DICHOTOMY  --  R = sum(d_i) - D is a curvature meter")

    s = [1.0, 1.0, 1.0]
    read_outs: List[Tuple[str, Callable[[float], float]]] = [
        ("affine        phi(x) = 0.3 x",         lambda x: 0.3 * x),
        ("convex        phi(x) = x^2",           lambda x: x * x),
        ("convex        phi(x) = exp(x) - 1",    lambda x: math.exp(x) - 1.0),
        ("concave       phi(x) = sqrt(max(x,0))", lambda x: math.sqrt(max(x, 0.0))),
        ("concave/clip  phi(x) = min(x, 1)",     lambda x: min(x, 1.0)),
        ("concave       phi(x) = log(1+x)",      lambda x: math.log1p(max(x, 0.0))),
    ]
    print(f"gains s = {s}   (S = {sum(s)})\n")
    print(f"{'read-out':<34}{'D':>10}{'sum d_i':>11}{'R':>11}   verdict")
    print("-" * 100)
    for name, phi in read_outs:
        D, d = block_and_single_drops(phi, s)
        R = sum(d) - D
        print(f"{name:<34}{D:>10.5f}{sum(d):>11.5f}{R:>11.5f}   {curvature_verdict(R, 1e-9)}")

    print("\n  Convex  =>  D <= sum d_i   (the block CANNOT hide)")
    print("  Affine  =>  D  = sum d_i")
    print("  Concave =>  sum d_i <= D    (the block CAN hide, gap unbounded)")

    print("\nApplied to the measurement:")
    d_meas = [MEASURED_S13_K2["ctl"] - MEASURED_S13_K2["zeroAt0"],
              MEASURED_S13_K2["ctl"] - MEASURED_S13_K2["zeroAt1"]]
    D_meas = MEASURED_S13_K2["ctl"] - MEASURED_S13_K2["zeroAll"]
    R_meas = sum(d_meas) - D_meas
    print(f"    R = {sum(d_meas):.4f} - {D_meas:.4f} = {R_meas:+.4f}"
          f"   ->  {curvature_verdict(R_meas)}")
    print(f"    worst-case bound from the no-op band: "
          f"R <= 2*{NOOP_BAND} - {D_meas:.4f} = {2*NOOP_BAND - D_meas:+.4f} < 0")
    print("    => no convex, a fortiori no affine, read-out fits this arm.")


# ---------------------------------------------------------------------------
# 4. The 1/k saturation law
# ---------------------------------------------------------------------------

def demo_saturation_law() -> None:
    banner("4.  THE 1/k SATURATION LAW  --  concavity manufactures redundancy")

    print("Concave phi, block gain S split equally over k coordinates.")
    print("Theory:  d_i <= (s_i/S) D = D/k,   while the block drop stays D.\n")

    S = 3.0
    for name, phi in [("sqrt(x)", lambda x: math.sqrt(max(x, 0.0))),
                      ("log(1+x)", lambda x: math.log1p(max(x, 0.0))),
                      ("min(x,1)", lambda x: min(x, 1.0))]:
        print(f"  phi = {name},  S = {S}")
        print(f"    {'k':>3}{'D':>10}{'max d_i':>11}{'D/k (bound)':>14}"
              f"{'sum d_i':>11}{'R':>11}")
        for k in (1, 2, 3, 4, 6, 8):
            s = [S / k] * k
            D, d = block_and_single_drops(phi, s)
            R = sum(d) - D
            print(f"    {k:>3}{D:>10.5f}{max(d):>11.5f}{D/k:>14.5f}"
                  f"{sum(d):>11.5f}{R:>11.5f}")
        print()

    print("  Every 'max d_i' column is dominated by its 'D/k' bound, and every")
    print("  R is <= 0.  A rising self-sufficiency rate with width is therefore")
    print("  the NULL expectation under saturation, not evidence of learning.")


# ---------------------------------------------------------------------------
# 5. An explicit item population that realizes the measured arm
# ---------------------------------------------------------------------------

@dataclass(frozen=True)
class ItemPopulation:
    """Item groups with masses summing to 1 and difficulty thresholds.

    A group is answered correctly exactly when the boundary gate value reaches
    its threshold, so accuracy at gate value gamma is the mass of all groups
    with threshold <= gamma.
    """

    mass: Tuple[float, ...]
    thr: Tuple[float, ...]

    def __post_init__(self) -> None:
        assert len(self.mass) == len(self.thr)
        assert all(m >= 0 for m in self.mass), "masses must be nonnegative"
        assert abs(sum(self.mass) - 1.0) < 1e-9, "masses must sum to 1"

    def acc(self, gamma: float) -> float:
        """Accuracy at boundary gate value `gamma` (monotone in gamma)."""
        return sum(m for m, t in zip(self.mass, self.thr) if t <= gamma)


def sat_gate(c: Sequence[float], clip: float = 1.0) -> float:
    """Rectified-and-clipped boundary gate  min(max(sum c_i, 0), clip)."""
    return min(max(sum(c), 0.0), clip)


S13_POPULATION = ItemPopulation(
    mass=(0.7544, 0.1523, 0.0913, 0.0020),
    thr=(0.0, 0.2, 0.5, 2.0),
)
S13_COEF: Tuple[float, float] = (1.0, 1.0)


def demo_realization() -> None:
    banner("5.  AN EXPLICIT REALIZATION OF THE MEASURED ARM")

    P, c = S13_POPULATION, list(S13_COEF)
    print("Item population (masses sum to 1):")
    for m, t in zip(P.mass, P.thr):
        print(f"    mass {m:.4f}   threshold {t}")
    print(f"\nExclusive coefficients c = {c},  gate = min(max(sum c, 0), 1)\n")

    rows: List[Tuple[str, List[float], float]] = [
        ("ctl",      c,                     MEASURED_S13_K2["ctl"]),
        ("zeroAt0",  zero_at(c, 0),         MEASURED_S13_K2["zeroAt0"]),
        ("zeroAt1",  zero_at(c, 1),         MEASURED_S13_K2["zeroAt1"]),
        ("zeroAll",  zero_all(c),           MEASURED_S13_K2["zeroAll"]),
        ("flipAt0",  flip_at(c, 0),         MEASURED_S13_K2["flipAt0"]),
        ("scale0.1", scale_all(c, 0.1),     MEASURED_S13_K2["scale0.1"]),
    ]
    print(f"{'intervention':<12}{'coefficients':>16}{'gate':>8}"
          f"{'model acc':>12}{'measured':>11}{'|residual|':>12}  ok?")
    print("-" * 78)
    ok_all = True
    for name, cc, meas in rows:
        gamma = sat_gate(cc)
        model = P.acc(gamma)
        res = abs(model - meas)
        ok = res <= MODEL_TOLERANCE
        ok_all = ok_all and ok
        print(f"{name:<12}{str([round(x,1) for x in cc]):>16}{gamma:>8.2f}"
              f"{model:>12.4f}{meas:>11.4f}{res:>12.4f}  {'yes' if ok else 'NO'}")
    print("-" * 78)
    print(f"All six reproduced within {MODEL_TOLERANCE}:  {ok_all}")

    print("\nThe model EXPLAINS rather than fits:")
    print("  - single ablations are no-ops because the gate is STILL saturated")
    print("    at 1 after removing one of two unit coordinates;")
    print("  - the flip is not, because it subtracts TWICE a coordinate;")
    print("  - the x0.1 rescale is not, because it drops the gate below every")
    print("    nonzero threshold except the lowest.")

    print("\nMonotone scale curve (a theorem of the model):")
    for lam in (0.0, 0.05, 0.1, 0.2, 0.3, 0.5, 1.0):
        print(f"    lambda = {lam:<5} gate = {sat_gate(scale_all(c, lam)):<5.2f}"
              f" acc = {P.acc(sat_gate(scale_all(c, lam))):.4f}")
    print(f"  ordering zeroAll <= scale <= ctl holds in the data too: "
          f"{MEASURED_S13_K2['zeroAll']} <= {MEASURED_S13_K2['scale0.1']}"
          f" <= {MEASURED_S13_K2['ctl']}")


# ---------------------------------------------------------------------------
# 6. The derived design rule
# ---------------------------------------------------------------------------

def channel_ladder(k: int, g: float = 1.0, clip: float = 1.0) -> Dict[str, float]:
    """Gate values of the canonical channel: k coordinates of equal gain g."""
    c = [g] * k
    out = {
        "ctl": sat_gate(c, clip),
        "zeroAll": sat_gate(zero_all(c), clip),
    }
    if k >= 1:
        out["zeroAt"] = sat_gate(zero_at(c, 0), clip)
    if k >= 1:
        out["flipAt"] = sat_gate(flip_at(c, 0), clip)
    return out


def demo_design_rule() -> None:
    banner("6.  THE DESIGN RULE, DERIVED (not fitted)")

    print("Canonical channel: k coordinates of equal gain g, gate min(max(.,0),T).")
    print("Surviving gain:  ctl -> k g ;  ablation -> (k-1) g ;  flip -> (k-2) g .")
    print("So: self-sufficient  iff  (k-1) g >= T ;  sign-robust  iff  (k-2) g >= T.\n")

    print("Unit gain g = 1, clip T = 1:")
    print(f"    {'k':>3}{'ctl':>8}{'zeroAt':>9}{'flipAt':>9}{'zeroAll':>10}"
          f"   self-sufficient?   sign-robust?")
    print("-" * 78)
    for k in (1, 2, 3, 4, 5):
        lad = channel_ladder(k, g=1.0, clip=1.0)
        selfsuf = abs(lad["zeroAt"] - lad["ctl"]) < 1e-12
        signrob = abs(lad["flipAt"] - lad["ctl"]) < 1e-12
        print(f"    {k:>3}{lad['ctl']:>8.2f}{lad['zeroAt']:>9.2f}"
              f"{lad['flipAt']:>9.2f}{lad['zeroAll']:>10.2f}"
              f"{'   yes' if selfsuf else '    no':>19}"
              f"{'   yes' if signrob else '    no':>15}")
    print("-" * 78)
    print("  =>  >= 2 exclusive dimensions for a self-sufficient recovery")
    print("  =>  >= 3 exclusive dimensions for sign robustness")
    print("  =>  the whole block is NEVER dispensable")
    print("\nThis is exactly the measured ladder:")
    print("    k = 1  ablation IS block ablation, destroys the channel")
    print("    k = 2  ablations no-op, flip breaks it (0.9980 -> 0.7505)")
    print("    k = 3  ablations AND flip are both no-ops")
    print("  So 'signs never matter' was a k = 3 statement:")
    print("  sign-sensitivity is WIDTH-CONDITIONAL.")

    print("\nThe dimensionless form: self-sufficiency iff (k-1)g/T >= 1.")
    print(f"    {'(k-1)g/T':>10}   self-sufficient?")
    for k, g, T in [(2, 1.0, 1.0), (2, 0.701, 1.0), (2, 0.660, 1.0),
                    (3, 0.701, 1.0), (2, 1.0, 1.5), (3, 1.0, 1.5)]:
        ratio = (k - 1) * g / T
        print(f"    k={k} g={g:<6} T={T:<4} ratio={ratio:>6.3f}   "
              f"{'yes' if ratio >= 1 else 'no'}")


# ---------------------------------------------------------------------------
# 7. Why k = 1 constrains nothing
# ---------------------------------------------------------------------------

def k1_witness(alpha: float, beta: float) -> ItemPopulation:
    """Population with control accuracy alpha and ablation accuracy beta.

    Requires 0 <= beta <= alpha <= 1.  Three groups at thresholds 0, 1, 2 with
    masses beta, alpha - beta, 1 - alpha.
    """
    assert 0.0 <= beta <= alpha <= 1.0
    return ItemPopulation(mass=(beta, alpha - beta, 1.0 - alpha),
                          thr=(0.0, 1.0, 2.0))


def demo_k1_unconstrained() -> None:
    banner("7.  WHY THE k = 1 ROWS CONSTRAIN NOTHING")

    print("Measured k = 1 arms (six seeds), control vs sole-coordinate ablation:\n")
    k1_data = [
        ("seed 8",  1.0000, 1.0000, "self-sufficient cure"),
        ("seed 9",  0.7622, 0.7432, "-0.019  (~2 SE, marginal)"),
        ("seed 10", 0.1606, 0.1592, "no-op (model had failed)"),
        ("seed 11", 0.8892, 0.8901, "no-op"),
        ("seed 12", 1.0000, 1.0000, "self-sufficient cure"),
        ("seed 13", 0.2734, 0.2510, "-0.022  (~2 SE, marginal)"),
    ]
    print(f"    {'arm':<9}{'ctl':>9}{'zero1':>9}{'delta':>9}   verdict")
    print("-" * 78)
    for name, ctl, z1, verdict in k1_data:
        print(f"    {name:<9}{ctl:>9.4f}{z1:>9.4f}{z1-ctl:>+9.4f}   {verdict}")

    print("\nEVERY one of these pairs is realizable in the model class:")
    print(f"    {'alpha':>8}{'beta':>9}   realized ctl / ablation")
    print("-" * 78)
    for name, ctl, z1, _ in k1_data:
        alpha, beta = ctl, min(z1, ctl)
        P = k1_witness(alpha, beta)
        got_ctl = P.acc(sat_gate([1.0]))
        got_abl = P.acc(sat_gate(zero_all([1.0])))
        print(f"    {alpha:>8.4f}{beta:>9.4f}   {got_ctl:.4f} / {got_abl:.4f}"
              f"   exact: {abs(got_ctl-alpha)<1e-12 and abs(got_abl-beta)<1e-12}")

    print("\n  For EVERY 0 <= beta <= alpha <= 1 such a population exists.")
    print("  Full cures, no-ops at failed arms and marginal partial losses all")
    print("  live in the same class => no k = 1 observation discriminates.")
    print("  A proportionality law read off from k = 1 arms therefore has no")
    print("  model-theoretic content, and its non-replication is expected.")

    print("\nBoundary-free arms are intervention-proof:")
    free = ItemPopulation(mass=(0.1606, 0.0, 0.8394), thr=(0.0, 1.0, 2.0))
    print(f"    acc(0) = {free.acc(0.0):.4f}  =  acc(gate) = {free.acc(1.0):.4f}")
    for gamma in (0.0, 0.1, 0.3, 0.7, 1.0):
        print(f"      gate {gamma:<4} -> acc {free.acc(gamma):.4f}   (no-op)")
    print("  A universal no-op is the signature of a channel that was NEVER")
    print("  READ -- not of one whose content has been absorbed elsewhere.")


# ---------------------------------------------------------------------------
# 8. The prediction the data refute
# ---------------------------------------------------------------------------

def demo_falsified_prediction() -> None:
    banner("8.  THE PREDICTION THE DATA REFUTE (and the repair)")

    print("At FIXED clip T, larger gains are MORE self-sufficient:")
    print("    self-sufficient  iff  (k-1) g >= T,  monotone increasing in g.\n")
    k, T = 2, 1.0
    for g in (0.40, 0.60, 0.660, 0.701, 0.90, 1.00, 1.20):
        ratio = (k - 1) * g / T
        print(f"    k={k}  g={g:<6} (k-1)g/T = {ratio:>6.3f}   "
              f"self-sufficient: {'yes' if ratio >= 1 else 'no'}")

    print("\nBut the DATA say the opposite: the single arm that stayed")
    print("boundary-dependent -- at BOTH k = 2 and k = 3, the same seed --")
    print("carries the LARGEST exclusive coordinates of its width")
    print("(0.701 versus at most 0.660 for its siblings).")
    print("\nUnder a seed-independent clip it should have been the MOST robust.")
    print("Conservative repair: the clip CO-SCALES with the coordinates, T = rho * g.")
    print("Then the dimensionless ratio is (k-1)g/T = (k-1)/rho -- the MAGNITUDE")
    print("g CANCELS, so the fixed-clip monotonicity dissolves entirely:\n")
    print(f"    {'g':>8}{'T = rho g':>12}{'(k-1)g/T':>11}   depends on g?")
    print("-" * 78)
    rho = 1.6
    for g in (0.40, 0.660, 0.701, 1.00):
        T_g = rho * g
        ratio = (k - 1) * g / T_g
        print(f"    {g:>8.3f}{T_g:>12.3f}{ratio:>11.3f}   no (= (k-1)/rho)")
    print("\n  With rho = 1.6 and k = 2 the ratio is 0.625 < 1 at EVERY magnitude,")
    print("  so an arm can stay dependent however large its coordinates are --")
    print("  which is what the s = 13 seed does at both k = 2 and k = 3.")
    print("  Width still helps, because the ratio is (k-1)/rho:")
    for kk in (2, 3, 4):
        print(f"      k = {kk}   (k-1)/rho = {(kk-1)/rho:.3f}   "
              f"{'self-sufficient' if (kk-1)/rho >= 1 else 'dependent'}")
    print("\n  The ratio form converts a seed idiosyncrasy into a measurable")
    print("  scalar (rho), and is testable on arms already scheduled.")


# ---------------------------------------------------------------------------

def main() -> None:
    print(__doc__.split("Run:")[0])
    demo_missing_middle()
    demo_affine_nogo()
    demo_convexity_dichotomy()
    demo_saturation_law()
    demo_realization()
    demo_design_rule()
    demo_k1_unconstrained()
    demo_falsified_prediction()
    banner("SUMMARY")
    print("""
  1.  A redundancy phenomenon needs k >= 2 to exist at all.  Below that the
      experiment measures a distinction that is not there.
  2.  The redundancy defect  R = sum_i d_i - D  has the SIGN OF THE CURVATURE
      of a nonlinearity one never observes directly:  R > 0 convex,
      R = 0 affine, R < 0 saturating.  Three accuracy numbers read it off.
  3.  Under saturation, single components look dispensable at rate 1/k for
      reasons of geometry alone.  When you delete a unit and nothing happens,
      you have learned something about the shape of a gate -- and possibly
      nothing at all about what the network knows.
  4.  Design rule, derived rather than fitted:  >= 2 exclusive dimensions for
      a self-sufficient recovery,  >= 3 for sign robustness.
""")


if __name__ == "__main__":
    main()
